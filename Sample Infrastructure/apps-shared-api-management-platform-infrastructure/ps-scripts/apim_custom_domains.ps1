param(  
    [Parameter(Mandatory=$True)]
	[string]
    $environmentType,

    [Parameter(Mandatory=$True)]
	[string]
    $primaryAzureLocationAbbrev,

	[Parameter(Mandatory=$True)]
	[string]
	$subscriptionId,

	[Parameter(Mandatory=$True)]
	[string]
	$tenantId,

	[Parameter(Mandatory=$True)]
	[string]
	$spnName,

	[Parameter(Mandatory=$True)]
	[SecureString]
    $spnPassword
)

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

az account set --subscription $subscriptionId

$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($spnName, $spnPassword)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
Set-AzContext -SubscriptionId $subscriptionId

$resourceGroupName = ""
$kvName = ""
$apimName = ""
$customDomainBrit = ""
$kvSecretBrit = ""
$customDomainKi = ""
$kvSecretKi = ""

switch($environmentType.ToLower())
{
	{ ($_ -in "prod", "prd") }
	{ 
        $resourceGroupName = "apps-shared-rg-$primaryAzureLocationAbbrev-prd"
        $kvName = "apps-shared-kv-prd"
        $apimName = "apps-shared-apimgmt-prd"
        $customDomainBrit = "api.britinsurance.com"
        $kvSecretBrit = "https://$kvName.vault.azure.net/secrets/api-britinsurance"
        $customDomainKi = "api.ki-insurance.com"
        $kvSecretKi = "https://$kvName.vault.azure.net/secrets/api-ki-insurance"
	}
	{ ($_ -in "test", "tst") }
	{
		$resourceGroupName = "apps-shared-rg-$primaryAzureLocationAbbrev-tst"
        $kvName = "apps-shared-kv-tst"
        $apimName = "apps-shared-apimgmt-tst"
        $customDomainBrit = "api-test.britinsurance.com"
        $kvSecretBrit = "https://$kvName.vault.azure.net/secrets/api-test-britinsurance"
        $customDomainKi = "api-test.ki-insurance.com"
        $kvSecretKi = "https://$kvName.vault.azure.net/secrets/api-test-ki-insurance"
	}	
}

$proxy1 = New-AzApiManagementCustomHostnameConfiguration -Hostname $customDomainBrit -HostnameType Proxy -KeyVaultId $kvSecretBrit
$proxy2 = New-AzApiManagementCustomHostnameConfiguration -Hostname $customDomainKi -HostnameType Proxy -KeyVaultId $kvSecretKi
$proxyCustomConfig = @($proxy1,$proxy2)
$apim = Get-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apimName
$apim.ProxyCustomHostnameConfiguration = $proxyCustomConfig 
Set-AzApiManagement -InputObject $apim

Write-Host "Custom domains updated successfully to API Management Service";