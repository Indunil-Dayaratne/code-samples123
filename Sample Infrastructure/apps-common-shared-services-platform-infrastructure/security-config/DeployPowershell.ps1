# This script requires:
#    Subscription created
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

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

Try{

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

# Key Vault Variables
$kvName = "brit-" + $applicationShortNamePrefix.ToLower() + "-kv-" + $environmentNameprefix.ToLower();

az keyvault set-policy --name $kvName --secret-permission get list set --spn $spnName

Write-Host "Access Policy assigned to SPN" -ForegroundColor Green
	
}
Catch
{
	$ErrorMessage = $_.Exception.Message

	Write-Host "Error: " + $ErrorMessage
}



