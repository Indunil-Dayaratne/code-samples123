param(
	[Parameter(Mandatory=$True)]
	[string]
	$subscriptionId,
	
	[Parameter(Mandatory=$True)]
	[string]
	$environmentNamePrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$tenantId,

	[Parameter(Mandatory=$True)]
	[string]
	$projectPrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$applicationPrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$location,

	[Parameter(Mandatory=$True)]
	[string]
	$spnName,

	[Parameter(Mandatory=$True)]
	[SecureString]
	$spnPassword
)

Import-Module Az.ApiManagement

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

if($location -eq "UK West")
{
	$locationAbbrev = "ukw";
}

$resourceGroupName = "apps-shared-rg-" + $locationAbbrev.ToLower() + "-" + $environmentNameprefix.ToLower();
$apiMgmtServiceName = "apps-shared-apimgmt-" + $environmentNameprefix.ToLower();
$functionName =  $applicationPrefix.ToLower() + "-func-" + $environmentNameprefix.ToLower();

$servicePath =  $applicationPrefix.ToLower() + "-" + $environmentNameprefix.ToLower();
$apiId = $applicationPrefix.ToLower() + "-api-" + $environmentNameprefix.ToLower();
$productId = $projectPrefix + "-" + $environmentNameprefix.ToLower(); 

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $spnName, $spnPassword
Connect-AzAccount -Credential $credential -Tenant $tenantId -ServicePrincipal

#Set-AzureContext -SubscriptionId $subscriptionId;

#Write-Host "Azure Context set to '$subscriptionId'" 

$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apiMgmtServiceName

Remove-AzApiManagementApi -Context $ApiMgmtContext -ApiId $apiId

$functionOperations = $($env:operationIds).Split()

$PN = $($env:pathNames).Split()

Write-Host "Path Names from Env Variable:"
Write-Host $PN

Write-Host "Following operations found:"
Write-Host $functionOperations

$paths = @{}

$PN | foreach { 
	$routeName = $_.Substring(0, $_.IndexOf(':'))
	$functionEndpointName = $_.Substring($_.IndexOf(':') + 1, ($_.length - $_.IndexOf(':') - 1) ) 
	$routes = $routeName.split("{{}")
	$parameters = @()
	$methods = @{}
	
	if ($routes.length -gt 1) {
		#Create parameters
		$routes | foreach {
			if (-Not $_.endswith('/')) {
				if (-Not $_.Trim() -eq '') {
					$parameters += @{
						"name" = $_.TrimEnd('?') 
						"in" = "path"
						"required" = $true
						"type" = "string"
					}
				}				
			}
		}
	}
	
	$functionOperations | foreach {
		$opName = $_.Substring(0, $_.IndexOf('-'))

		$endPointName =  $_.Substring($_.IndexOf('-') + 1, ($_.length - $_.IndexOf('-') - 1) )
		$functionEndpointName = $functionEndpointName.TrimStart('/')

		if ($functionEndpointName.IndexOf('/') -gt 0) {
			$functionEndpointName = $functionEndpointName.Substring(0, $functionEndpointName.IndexOf('/'))
		}

		if ($endPointName -eq $functionEndpointName) {
			Write-Host $opName
			Write-Host $endPointName
			$methods += @{
				$opName = @{
				"operationId" = $_
				"summary" = $endPointName
				"parameters" = $parameters
				"responses" = @{}
				}
			}
		}	
    }    
	
	$paths += @{ $routeName = $methods
        }
}

$jsonRequest = [ordered]@{
    swagger = "2.0"
    info= @{
        title = $functionName
        version = "1.0"
        description = "Import from $functionName Function App"
    }
    host = "$functionName.azurewebsites.net"
    basePath = "/$($env:routePrefix)"
    schemes = @(
        "https"
    )
    paths = $paths
    tags = @()
}

$fileName = ".\" + $functionName + ".swagger.json"

$jsonRequest | ConvertTo-Json -Depth 100 | Out-File $fileName

Write-Host "Swagger generated: "
Get-Content -Path $fileName

Import-AzApiManagementApi -Context $ApiMgmtContext -SpecificationFormat "Swagger" -SpecificationPath $fileName -Path $servicePath -ApiId $apiId

$sourceBasePath = "https://"+$jsonRequest.host+$jsonRequest.basePath;
$targetbasePath = "https://$apiMgmtServiceName.azure-api.net/"+$applicationPrefix.ToLower()+"-"+$environmentNameprefix.ToLower();

$PolicyString = '<policies><inbound><cors allow-credentials="false"><allowed-origins><origin>*</origin></allowed-origins><allowed-methods><method>*</method></allowed-methods><allowed-headers><header>*</header></allowed-headers><expose-headers><header>*</header></expose-headers></cors></inbound><outbound><base/><find-and-replace from="'+$sourceBasePath+'" to="'+$targetbasePath+'"/></outbound></policies>'
$functionOperations | foreach {
    Set-AzApiManagementPolicy -Context $ApiMgmtContext -ApiId $apiId -OperationId $_ -Format "application/vnd.ms-az-apim.policy.raw+xml" -Policy $PolicyString
}

$apiMgmtProduct = Get-AzApiManagementProduct -Context $ApiMgmtContext -ProductId $productId

if (!$apiMgmtProduct) {
    New-AzApiManagementProduct -Context $ApiMgmtContext -ProductId $productId -Title $productId -Description "$projectPrefix APIs" -LegalTerms "Free for all" -SubscriptionRequired $False -State "Published"
}

Add-AzApiManagementApiToProduct -Context $ApiMgmtContext -ProductId $productId -ApiId $apiId

Write-Host "API Imported successfully"