param(
	[Parameter(Mandatory=$True)]
	[string]
	$subscriptionId,

	[Parameter(Mandatory=$True)]
	[string]
	$tenantId,

	[Parameter(Mandatory=$True)]
	[string]
	$resourceGroupName,

    [Parameter(Mandatory=$True)]
	[string]
	$appName,

	[Parameter(Mandatory=$True)]
	[string]
	$spnName,

	[Parameter(Mandatory=$True)]
	[SecureString]
	$spnPassword,

	[Parameter(Mandatory=$False)]
	[string]
	$useSameRestrictionsForScmSite
)

#Import-Module AzureRM

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params
try 
{
    az account set --subscription $subscriptionId
    az webapp config access-restriction set -g $resourceGroupName -n $appName --use-same-restrictions-for-scm-site $useSameRestrictionsForScmSite --only-show-errors

    Write-Host "Use-Same-Restrictions-For-SCM-Site set to $useSameRestrictionsForScmSite for the App Service $appName in the Resource Group $resourceGroupName"
}
catch 
{
    $ErrorMessage = $_.Exception.Message

	Write-Host "Error: " + $ErrorMessage
}


