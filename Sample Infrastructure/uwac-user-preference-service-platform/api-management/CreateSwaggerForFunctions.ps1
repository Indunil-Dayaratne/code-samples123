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
	$applicationShortNamePrefix,

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

Import-Module AzureRM

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

if($location -eq "UK West")
{
	$locationAbbrev = "ukw";
}

$resourceGroupName = $projectPrefix.ToLower() + "-" + $applicationShortNamePrefix.ToLower() + "-rg-" + $locationAbbrev.ToLower() + "-" + $environmentNameprefix.ToLower();

$resourceType = "Microsoft.Web/sites/config"
$functionName =  $applicationPrefix.ToLower() + "-func-" + $environmentNameprefix.ToLower();
$resourceName = $functionName+"/publishingcredentials"

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

# $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $spnName, $spnPassword
# Connect-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $tenantId

Set-AzureRmContext -SubscriptionId $subscriptionId;

Write-Host "Azure Context set to '$subscriptionId'" 
$operationIdList = @()
$pathNames = @()

$publishingCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion 2015-08-01 -Force

$kuduApiAuthorisationToken = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword)))

$functions = Get-AzureRmResource -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Web/sites/functions" -ResourceName $functionName -ApiVersion '2018-02-01'

Write-Host $functions

$paths = @{}

Write-Host "Reading operations from function object..."

$functionConfig = Invoke-RestMethod -Uri ("https://$functionName.scm.azurewebsites.net/api/functions/config".Trim() ) -Method GET -Headers @{"Authorization"=$kuduApiAuthorisationToken;"If-Match"="*"};
$functionRoutePrefix = $functionConfig.extensions.http.routePrefix;

$functions | foreach { 
    $endPointName = $_.Name.Substring($_.Name.LastIndexOf('/') + 1, ($_.Name.length - $_.Name.LastIndexOf('/') - 1))
    $endPointPath = "https://$functionName.scm.azurewebsites.net/api/vfs/site/wwwroot/$endPointName"
    $functionEndPoint = Invoke-RestMethod -Uri ($endPointPath.Trim() + "/function.json") -Method GET -Headers @{"Authorization"=$kuduApiAuthorisationToken;"If-Match"="*"}
    Write-Host $functionEndPoint
	$httpBinding = $functionEndPoint.bindings | where { $_.type -eq "httpTrigger" }
	
	if ($httpBinding) {
		$httpMethods = $httpBinding.methods
		$httpRoute = $httpBinding.route
		$pathName = '/' + $endPointName
		if ($httpRoute) {
			$pathName = '/' + ($httpRoute -replace '[?]','')
		}
		$pathNames += ($pathName + ":" + $endPointName)
			
		$httpMethods | foreach {
			Write-Host $_
			$operationIdList += @($_+"-"+$endPointName.TrimStart("/"))        
		}   
	}	 
}

Write-Host $jsonRequest

Write-Host "##vso[task.setvariable variable=routePrefix;]$functionRoutePrefix"

Write-Host "##vso[task.setvariable variable=pathNames;]$pathNames"

Write-Host "##vso[task.setvariable variable=operationIds;]$operationIdList"

Write-Host "Path names and operations saved successfully to environment variables"
