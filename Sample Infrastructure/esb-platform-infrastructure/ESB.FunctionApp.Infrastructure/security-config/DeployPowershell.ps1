# This script requires:
#    Subscription created
param(
	[Parameter(Mandatory=$True)]
	[string]
	$subscriptionId,

	[Parameter(Mandatory=$True)]
	[string]
	$environmentNamePrefix,`

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
	$spnPassword,

	[Parameter(Mandatory=$True)]
	[string]
	$applicationPrefixShortName,

	[Parameter(Mandatory=$True)]
	[string]
	$legacyEnvironmentNamePrefix
)

Import-Module AzureRM

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

if($location -eq "UK West")
{
	$locationAbbrev = "ukw";
}

$resourceGroupName = "rg-" + $legacyEnvironmentNamePrefix.ToLower() + "-" + $applicationPrefixShortName.ToLower() + "-" + $locationAbbrev.ToLower() + "-01";

function GetOrCreateKeyVault($name,$rgName,$location,$tenantId,$subscriptionId,$keyPrefix) {
	$keyVault = Get-AzureRmKeyVault -Name $name -ResourceGroupName $rgName -ErrorAction SilentlyContinue
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
$functionName =  $applicationPrefix.ToLower() + "-func-" + $legacyEnvironmentNamePrefix.ToLower();
$functionStorageName =  $applicationPrefixShortName.ToLower() + "funcstorage" + $locationAbbrev + $legacyEnvironmentNamePrefix.ToLower();
$storageAccountName = $legacyEnvironmentNamePrefix.ToLower() + $applicationPrefixShortName.ToLower() + "store";
$appInsightName = $applicationPrefix.ToLower() + "-appins-" + $legacyEnvironmentNamePrefix.ToLower();
$signalRServiceName = $applicationPrefix.ToLower() + "-signalr-" + $legacyEnvironmentNamePrefix.ToLower();

# Key Vault Variables
$kvName = "apps-shared-kv-" + $environmentNameprefix.ToLower();
$commonRGName = "apps-shared-rg-" + $locationAbbrev + "-" + $environmentNameprefix.ToLower();

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
$keyVault =  GetOrCreateKeyVault -name $kvName -rgName $commonRGName -location $location -tenantId $tenantId -subscriptionId $subscriptionId
if(!$keyVault) {
	Write-Output "Key Vault resource does not exist.";
	exit
}

# GET FUNCTION APP
$funcApp = Get-FunctionApp -functionName $functionName

if(!$funcApp)
{
	Write-Output "FunctionApp resource does not exist.";
	exit
	
}	

Write-Output "Function AD Registraton"

$params = "--output","json","--display-name",$functionName
$funcAdAppList = az ad app list @params
$funcAdAppListJson = $funcAdAppList | ConvertFrom-Json

$functionUrl = "https://" + $functionName + ".azurewebsites.net"

$aadAppClientId = ""
$aadAppClientSecret = ""

if($funcAdAppListJson.Length -lt 1) {

	$functionReplyUrl = @("https://$functionName.azurewebsites.net/.auth/login/aad/callback", "https://$functionName.azurewebsites.net")

	Write-Host "Create AAD entry for application $functionName"
	$params = "--output","json","--display-name","$functionName","--identifier-uris",$functionUrl,"--reply-urls",$functionReplyUrl,"--homepage",$functionUrl,"--oauth2-allow-implicit-flow","true"
	$funcAdApp = az ad app create @params

	# Update Authentication to AD for Function
	Write-Host "Enabling AAD Authentication within $functionName"

	$funcAdAppJson = $funcAdApp | ConvertFrom-Json

	$aadAppClientId = $funcAdAppJson.appId
	
	$issuerUrl = "https://sts.windows.net/" + $tenantId
	$params = "-g",$resourceGroupName,"-n",$functionName,"--enabled","true","--action","LoginWithAzureActiveDirectory","--aad-allowed-token-audiences",$functionReplyUrl,"--aad-client-id",$funcAdAppJson.appId,"--aad-token-issuer-url",$issuerUrl,"--token-store","true"
	$funcAuth = az webapp auth update @params

} 
else {
	$aadAppClientId = $funcAdAppListJson[0].appId
}

# KEY VAULT SECRETS
Write-Host "Reading secrets from $kvName"
$secrets = az keyvault secret list --vault-name $kvName --output json
$jsonsecrets = $secrets | ConvertFrom-Json

$kvSecretNameClientId = $applicationPrefix + "-" + $environmentNameprefix.ToLower() + "-client-id"

if(!($jsonsecrets | where {$_.id.endswith("/$kvSecretNameClientId") })) {	
    Write-Host "Writing secret $kvSecretNameClientId to $aadAppClientId"
    az keyvault secret set --name $kvSecretNameClientId --vault-name $kvName --value $aadAppClientId
}	

# FUNC SETTINGS
$funcKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $functionStorageName
$accountKey =  $funcKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
$funcStorageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$functionStorageName + ";AccountKey=" + $accountKey.Value

$accountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName
$accountKey =  $accountKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
$storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$storageAccountName + ";AccountKey=" + $accountKey.Value

$signalRAccessKey = az signalr key list -n $signalRServiceName -g $resourceGroupName --query primaryKey -o tsv
$signalRConnectionString = "Endpoint=https://"+$signalRServiceName+".service.signalr.net;AccessKey="+$signalRAccessKey+";Version=1.0;"

$funcAppSettings = Get-FunctionAppSettings -functionName $functionName 

$appInsightsInstrumentationKey = $appInsights.InstrumentationKey;

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsDashboard" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsStorage" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_EXTENSION_VERSION" -settingValue "-1"

Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_WORKER_RUNTIME" -settingValue "dotnet"

Set-FunctionAppSetting -functionName $functionName -settingName "MSGRAPH_RESOURCEID" -settingValue "https://graph.microsoft.com"

Set-FunctionAppSetting -functionName $functionName -settingName "KeyVaultApiVersion" -settingValue "7.0"

Set-FunctionAppSetting -functionName $functionName -settingName "KeyVaultBaseUrl" -settingValue "https://apps-shared-kv-$environmentNamePrefix.vault.azure.net/secrets/"

Set-FunctionAppSetting -functionName $functionName -settingName "KeyVaultUrl" -settingValue "https://vault.azure.net"

Set-FunctionAppSetting -functionName $functionName -settingName "CacheExpiryTimeInMinutes" -settingValue "30"

Set-FunctionAppSetting -functionName $functionName -settingName "APPINSIGHTS_INSTRUMENTATIONKEY" -settingValue $appInsightsInstrumentationKey

Set-FunctionAppSetting -functionName $functionName -settingName "tenantid" -settingValue $tenantId

Set-FunctionAppSetting -functionName $functionName -settingName "OpenIdConfigurationEndPoint" -settingValue "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"

Set-FunctionAppSetting -functionName $functionName -settingName "ValidIssuers" -settingValue "https://login.microsoftonline.com/$tenantId/v2.0,https://sts.windows.net/$tenantId/"

Set-FunctionAppSetting -functionName $functionName -settingName "audience" -settingValue "https://$functionName.azurewebsites.net"

Set-FunctionAppSetting -functionName $functionName -settingName "BEASBaseUrl" -settingValue "https://beas-func-$environmentNamePrefix.azurewebsites.net/api"

Set-FunctionAppSetting -functionName $functionName -settingName "AzureStorageConnectionString" -settingValue $storageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "AzureSignalRConnectionString" -settingValue $signalRConnectionString 

Set-FunctionAppSetting -functionName $functionName -settingName "NotificationTableName" -settingValue "notificationlog" 

Set-FunctionAppSetting -functionName $functionName -settingName "NotificationSubscriberTableName" -settingValue "notificationsubscriber" 

Set-FunctionAppSetting -functionName $functionName -settingName "DaysForNotifications" -settingValue "21" 

Set-FunctionAppSetting -functionName $functionName -settingName "AccessRole" -settingValue "Notifications" 

Set-FunctionAppSetting -functionName $functionName -settingName "BeasClientIdKey" -settingValue "beas-$legacyEnvironmentNamePrefix-client-id"

# Set Function Cors and Credentials Support
if($funcApp) {
    Write-Host "Adding CORS support to function app"
	# Credentials Support
	$params = "--name","web","--resource-group",$resourceGroupName,"--resource-type","config","--set","properties.cors.supportCredentials=true","--namespace","Microsoft.Web","--parent","sites/$functionName"
	az resource update @params
    # Cors Support
    if ($environmentNamePrefix.ToLower() -eq "prd")
    {
        $webAppDefaultUrl = "https://opus"
    }
	elseif ($environmentNamePrefix.ToLower() -eq "stg")
	{
		$webAppDefaultUrl = "https://opus-staging"
	}
	else 
	{
        $webAppDefaultUrl = "https://opus-$legacyEnvironmentNamePrefix"
    }
    
	$params = "--name",$functionName,"--resource-group",$resourceGroupName,"--allowed-origins",$webAppDefaultUrl
	az functionapp cors add @params
}

Write-Host "Assigning Function App MSI"
$funcMsi = az webapp identity assign --resource-group $resourceGroupName --name $functionName

$funcMsiJson = $funcMSI | ConvertFrom-Json

az keyvault set-policy --name $kvName --object-id $funcMsiJson.principalid --secret-permissions get list

#Write-Host "Enable AAD Authentication on Function App"
#az webapp auth update  --resource-group $resourceGroupName --name $functionName --enabled true --action LoginWithAzureActiveDirectory --aad-allowed-token-audiences "https://$functionName.azurewebsites.net/.auth/login/aad/callback" "https://$functionName.azurewebsites.net" --aad-client-id $aadAppClientId --aad-client-secret $aadAppClientSecret --aad-token-issuer-url "https://sts.windows.net/$tenantId/"

# Write-Host "Add permission to Sign-in and read user profile"
# az ad app permission add --id $aadAppClientId --api 00000002-0000-0000-c000-000000000000 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope

# az ad app permission grant --id $aadAppClientId --api 00000002-0000-0000-c000-000000000000 

# az ad app permission admin-consent --id $aadAppClientId 

Write-Host "App Created" -ForegroundColor Green
	
}
Catch
{
	$ErrorMessage = $_.Exception.Message

	Write-Host "Error: " + $ErrorMessage
}



