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
	$spnName,

	[Parameter(Mandatory=$True)]
	[SecureString]
	$spnPassword
)

Import-Module AzureRM

# Main Variables

$locationAbbrev = "uks";

if($location -eq "UK West")
{
	$locationAbbrev = "ukw";
}

$resourceGroupName = $projectPrefix.ToLower() + "-" + $applicationShortNamePrefix.ToLower() + "-rg-" + $locationAbbrev.ToLower() + "-" + $environmentNameprefix.ToLower();

function GetOrCreateKeyVault($name,$resourceGroupName,$location,$tenantId,$subscriptionId,$keyPrefix) {
	$keyVault = Get-AzureRmKeyVault -Name $name -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
	if(!$keyVault)
	{
		Write-Output "Key Vault resource does not exist.";
	    exit
    }

	return $keyVault
}

function Get-FunctionApp {
	param([string]$functionName)

	$params = "--output","json","--resource-group",$resourceGroupName,"--name",$functionName
	$funcApp = az functionapp show @params

	return $funcApp
}

function Get-FunctionAppSettings {
	param([string]$functionName)

	$params = "--output","json","--resource-group",$resourceGroupName,"--name",$functionName
	$settingList = az functionapp config appsettings list @params
	$settingListJson = $settingList | ConvertFrom-Json
	return $settingListJson
}

function Set-FunctionAppSetting { 
	param([string]$functionName, [string]$settingName, [string]$settingValue)

	$funcAppSettings = Get-FunctionAppSettings -functionName $functionName 

	if(!($funcAppSettings | Where-Object { $_.name -eq $settingName})) {
		Write-Host "Updating FunctionApp Application Setting - $settingName";
		az functionapp config appsettings set --name $functionName --resource-group $resourceGroupName --settings "$settingName=$settingValue"
	}
}
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

Set-AzureRmContext -SubscriptionId $subscriptionId;

Write-Host "Azure Context set to '$subscriptionId'" 

Try{

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

# Function Variables
$functionName =  $applicationPrefix.ToLower() + "-func-" + $environmentNameprefix.ToLower();
$functionStorageName =  $storageAccountNamePrefix + $locationAbbrev.ToLower() + $environmentNameprefix.ToLower();
$appInsightName = $applicationPrefix.ToLower() + "-appins-" + $environmentNameprefix.ToLower();
#$functionKvName = $functionName + "-appid"

# Key Vault Variables
$kvName = $applicationShortNamePrefix.ToLower() + "-kv-" + $environmentNameprefix.ToLower();

# RESOURCE GROUP
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction Stop 
if(!$resourceGroup)
{
	Write-Host "Resource group '$resourceGroupName' does not exist.";
    exit
}

# APP INSIGHTS
$appInsights = Get-AzureRmApplicationInsights -ResourceGroupName $resourceGroupName -Name $appInsightName -ErrorAction Stop
if(!$appInsights) {
	Write-Output "App Insights resource does not exist.";
	exit
}

# KEYVAULT
$keyVault =  GetOrCreateKeyVault -name $kvName -resourceGroupName $resourceGroupName -location $location -tenantId $tenantId -subscriptionId $subscriptionId
if(!$keyVault) {
	Write-Output "Key Vault resource does not exist.";
	exit
}

$tenantIdString =ConvertTo-SecureString -String $tenantId -AsPlainText -Force
$subscriptionIdString = ConvertTo-SecureString -String $subscriptionId -AsPlainText -Force
$tenantIdKvName = "TenantId"
$subscriptionIdKvName = "SubscriptionId"

az keyvault set-policy --name $kvName --secret-permission get list set --spn $spnName

# KEY VAULT SECRETS
Write-Host "Reading secrets from $kvName"
$secrets = az keyvault secret list --vault-name $kvName --output json
$jsonsecrets = $secrets | ConvertFrom-Json

#$secret1 = az keyvault secret show --vault-name $kvName --name $tenantIdKvName 

if(!($jsonsecrets | where {$_.id.endswith("/$tenantIdKvName") })) {	
    Write-Host "Writing secret $tenantIdKvName to $kvName"
    az keyvault secret set --name $tenantIdKvName --vault-name $kvName --value $tenantIdString
}

#$secret2 = az keyvault secret show --vault-name $kvName --name $subscriptionIdKvName 
if(!($jsonsecrets | where {$_.id.endswith("/$subscriptionIdKvName") })) {	
    Write-Host "Adding secret $subscriptionIdKvName to $kvName"
    az keyvault secret set --name $subscriptionIdKvName --vault-name $kvName --value $subscriptionIdString 
}

# GET FUNCTION APP
#$funcApp = Get-AzureRmResource -Name $functionName -ResourceGroupName $resourceGroupName -ErrorAction Continue

$funcApp = Get-FunctionApp -functionName $functionName

if(!$funcApp)
{
	Write-Output "FunctionApp resource does not exist.";
	exit
	
}	

Write-Output "Function App Settings"

# FUNC SETTINGS
$funcKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $functionStorageName
$accountKey =  $funcKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
$funcStorageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$functionStorageName + ";AccountKey=" + $accountKey.Value

$funcAppSettings = Get-FunctionAppSettings -functionName $functionName 

$appInsightsInstrumentationKey = $appInsights.InstrumentationKey;

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsDashboard" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsStorage" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_EXTENSION_VERSION" -settingValue "-1"

Set-FunctionAppSetting -functionName $functionName -settingName "MSGRAPH_RESOURCEID" -settingValue "https://graph.microsoft.com"

Set-FunctionAppSetting -functionName $functionName -settingName "KEYVAULT_RESOURCEID" -settingValue "https://$kvName.vault.azure.net/secrets/"

Set-FunctionAppSetting -functionName $functionName -settingName "APPINSIGHTS_INSTRUMENTATIONKEY" -settingValue $appInsightsInstrumentationKey

Set-FunctionAppSetting -functionName $functionName -settingName "tenantid" -settingValue $tenantId

Get-ChildItem Env: | Where-Object { $_.Name -like "AppSetting:*" } | ForEach-Object { 
	Set-FunctionAppSetting -functionName $functionName -settingName $_.Name.Substring(11) -settingValue $_.Value
}

# Set Function Cors and Credentials Support

Write-Host "Assigning Function App MSI"
$funcMsi = az webapp identity show --resource-group $resourceGroupName --name $functionName
if(!$funcMsi)
{
	$funcMsi = az webapp identity assign --resource-group $resourceGroupName --name $functionName
}

$funcMsiJson = $funcMSI | ConvertFrom-Json

$params = "--name",$kvName,"--object-id",$funcMsiJson.principalid,"--secret-permissions","get"

az keyvault set-policy @params

Write-Host "Checking AD Group"
$adGroupName = $applicationShortNamePrefix.ToLower() + "-group-" + $environmentNameprefix.ToLower();
$adGroup = ''
$adGroup = az ad group list --display-name $adGroupName
$adGroupJson = $adGroup | ConvertFrom-Json

if (!$adGroupJson)
{
	$adGroup = az ad group create --display-name $adGroupName --mail-nickname $adGroupName
	$adGroupJson = $adGroup | ConvertFrom-Json
}

Write-Host "Adding Function MSI to AD Group"
$existsInGroup = az ad group member check --group $adGroupName --member-id $funcMsiJson.principalid
$existsInGroupJson = $existsInGroup | ConvertFrom-Json

if ($existsInGroupJson.value -eq $false)
{
	az ad group member add --group $adGroupJson.objectId --member-id  $funcMsiJson.principalid
}

Write-Host "App Created" -ForegroundColor Green
	
}
Catch
{
	$ErrorMessage = $_.Exception.Message

	Write-Host "Error: " + $ErrorMessage
}





