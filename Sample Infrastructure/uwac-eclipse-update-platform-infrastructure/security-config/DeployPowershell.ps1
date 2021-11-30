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
	$functionPrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$britCacheServiceUrl,

	[Parameter(Mandatory=$True)]
	[string]
	$legacyEnvironmentNamePrefix,

	[Parameter(Mandatory=$False)]
	[string]
	$eclipseBaseUri,

	[Parameter(Mandatory=$False)]
	[string]
	$eclipseDefaultUri,

	[Parameter(Mandatory=$True)]
	[string]
	$esbBaseUrl,

	[Parameter(Mandatory=$True)]
	[string]
	$esbConnectionString,

	[Parameter(Mandatory=$True)]
	[string]
	$tpuBaseUrl
)

Import-Module AzureRM

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

if($location -eq "UK West")
{
	$locationAbbrev = "ukw";
}

$resourceGroupName = $projectPrefix + "-" + $applicationPrefix.ToLower() + "-rg-" + $locationAbbrev + "-" + $environmentNameprefix.ToLower();

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
$functionName =  $applicationPrefix.ToLower() + "-" + $functionPrefix + "-func-" + $environmentNameprefix.ToLower();
$functionStorageName =  $applicationPrefixShortName.ToLower() + "funcstorage" + $locationAbbrev + $environmentNameprefix.ToLower();
$esbStorageAccountName = $legacyEnvironmentNamePrefix.ToLower() + "esbstore";
$esbRGName = "rg-" + $legacyEnvironmentNamePrefix.ToLower() + "-esb-uks-01";
$appInsightName = $applicationPrefix.ToLower() + "-appins-" + $environmentNameprefix.ToLower();

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

$kvSecretNameClientId = $applicationPrefix + "-" + $functionPrefix + "-" + $environmentNameprefix.ToLower() + "-client-id"

if(!($jsonsecrets | where {$_.id.endswith("/$kvSecretNameClientId") })) {	
    Write-Host "Writing secret $kvSecretNameClientId to $aadAppClientId"
    az keyvault secret set --name $kvSecretNameClientId --vault-name $kvName --value $aadAppClientId
}

$validatorKvSecretNameClientId = $applicationPrefix + "-validator-" + $environmentNameprefix.ToLower() + "-client-id"
$validatorClientId = az keyvault secret show --name $validatorKvSecretNameClientId --vault-name $kvName --query value -o tsv

# FUNC SETTINGS
$funcKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $functionStorageName
$accountKey =  $funcKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
$funcStorageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$functionStorageName + ";AccountKey=" + $accountKey.Value

 $accountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $esbRGName -Name $esbStorageAccountName
 $accountKey =  $accountKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
 $storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$esbstorageAccountName + ";AccountKey=" + $accountKey.Value

$funcAppSettings = Get-FunctionAppSettings -functionName $functionName 

$appInsightsInstrumentationKey = $appInsights.InstrumentationKey;

$eclipseUpdateKvName = "eclipse-update-kv-" + $environmentNameprefix.ToLower();

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsDashboard" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsStorage" -settingValue $funcStorageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_EXTENSION_VERSION" -settingValue "-1"

Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_WORKER_RUNTIME" -settingValue "dotnet"

Set-FunctionAppSetting -functionName $functionName -settingName "MSGRAPH_RESOURCEID" -settingValue "https://graph.microsoft.com"

Set-FunctionAppSetting -functionName $functionName -settingName "KEYVAULT_RESOURCEID" -settingValue "https://$eclipseUpdateKvName.vault.azure.net/secrets/"

Set-FunctionAppSetting -functionName $functionName -settingName "CacheExpiryTimeInMinutes" -settingValue "30"

Set-FunctionAppSetting -functionName $functionName -settingName "APPINSIGHTS_INSTRUMENTATIONKEY" -settingValue $appInsightsInstrumentationKey

Set-FunctionAppSetting -functionName $functionName -settingName "tenantid" -settingValue $tenantId

Set-FunctionAppSetting -functionName $functionName -settingName "OpenIdConfigurationEndPoint" -settingValue "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"

Set-FunctionAppSetting -functionName $functionName -settingName "ValidIssuers" -settingValue "https://login.microsoftonline.com/$tenantId/v2.0,https://sts.windows.net/$tenantId/"

Set-FunctionAppSetting -functionName $functionName -settingName "audience" -settingValue "https://$functionName.azurewebsites.net"

Set-FunctionAppSetting -functionName $functionName -settingName "BEASBaseUrl" -settingValue "https://beas-func-$environmentNamePrefix.azurewebsites.net/api"

Set-FunctionAppSetting -functionName $functionName -settingName "ESBStorageConnectionString" -settingValue $storageAccountConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "BeasClientIdKey" -settingValue "beas-$environmentNamePrefix-client-id"

Set-FunctionAppSetting -functionName $functionName -settingName "BritCacheServiceUrl" -settingValue $britCacheServiceUrl

Set-FunctionAppSetting -functionName $functionName -settingName "WEBSITE_DNS_SERVER" -settingValue "10.3.1.6"

Set-FunctionAppSetting -functionName $functionName -settingName "DestinationESBQueue" -settingValue "eclipse-policy-in"

Set-FunctionAppSetting -functionName $functionName -settingName "Domain" -settingValue "wren"

Set-FunctionAppSetting -functionName $functionName -settingName "ESBBaseUrl" -settingValue $esbBaseUrl

Set-FunctionAppSetting -functionName $functionName -settingName "EsbConnectionString" -settingValue $esbConnectionString

Set-FunctionAppSetting -functionName $functionName -settingName "NotificationTableName" -settingValue "Notification"

Set-FunctionAppSetting -functionName $functionName -settingName "SourcePolicyUpdateESBQueue" -settingValue "eclipse-policy-update-in"

Set-FunctionAppSetting -functionName $functionName -settingName "SourcePolicyCreateESBQueue" -settingValue "eclipse-policy-create-in"

Set-FunctionAppSetting -functionName $functionName -settingName "TPUBaseUrl" -settingValue $tpuBaseUrl

Set-FunctionAppSetting -functionName $functionName -settingName "TPUCommentsListName" -settingValue "TPU Comments"

Set-FunctionAppSetting -functionName $functionName -settingName "TPUListName" -settingValue "TPU"

Set-FunctionAppSetting -functionName $functionName -settingName "EclipseValidatorClientId" -settingValue $validatorClientId

Set-FunctionAppSetting -functionName $functionName -settingName "EclipseRetrySleepDurations" -settingValue "00:00:01,00:00:02"

Set-FunctionAppSetting -functionName $functionName -settingName "EclipseValidatorBaseUrl" -settingValue "https://eclipse-update-validator-func-$environmentNamePrefix.azurewebsites.net/api/"

if ($eclipseBaseUri)
{
	Set-FunctionAppSetting -functionName $functionName -settingName "EclipseBaseUri" -settingValue $eclipseBaseUri
}

if ($eclipseDefaultUri)
{
	Set-FunctionAppSetting -functionName $functionName -settingName "EclipseDefaultUri" -settingValue $eclipseDefaultUri
}

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


Write-Host "App Created" -ForegroundColor Green
	
}
Catch
{
	$ErrorMessage = $_.Exception.Message

	Write-Host "Error: " + $ErrorMessage
}



