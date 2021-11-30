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
	$applicationShortNamePrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$storageAccountNamePrefix,

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
	$userPreferenceApplicationName,

	[Parameter(Mandatory=$True)]
	[string]
	$userPreferenceApplicationRole,

	[Parameter(Mandatory=$True)]
	[string]
	$beasBaseUrl,

	[Parameter(Mandatory=$False)]
	[string]
	$deployFrontDoor = "False"
)

Import-Module AzureRM

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

$global:aadAppClientId = ""
$global:aadAppClientSecret = [system.web.security.membership]::GeneratePassword(10,0)
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

function SetupSettings(){
	param([string]$locationAbbrev)
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
	$appsSharedKvName = "apps-shared-kv-" + $environmentNameprefix.ToLower();

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
	az keyvault set-policy --name $appsSharedKvName --secret-permission get list set --spn $spnName
	

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

	$webAppDefaultUrl = ""

	if($funcApp) {
		Write-Host "Adding CORS support to function app"
		# Credentials Support
		$params = "--name","web","--resource-group",$resourceGroupName,"--resource-type","config","--set","properties.cors.supportCredentials=true","--namespace","Microsoft.Web","--parent","sites/$functionName"
		az resource update @params

		# Cors Support
		switch($environmentNamePrefix.ToLower())
		{
			{ ($_ -in "prod", "prd") }
			{ 
				$webAppDefaultUrl = "https://opus" 
			}
			"tst"
			{
				$webAppDefaultUrl = "https://opus-test"
			}
			"stg" 
			{
				$webAppDefaultUrl = "https://opus-staging"
			}
			default
			{
				$webAppDefaultUrl = "https://opus-$environmentNamePrefix"
			}
		}
		$params = "--name",$functionName,"--resource-group",$resourceGroupName,"--allowed-origins",$webAppDefaultUrl
		az functionapp cors add @params
	}
	$loginRedirectUrl = $webAppDefaultUrl + "/Home/LoginRedirect"
	$redirectUrls = $webAppDefaultUrl+" "+ $loginRedirectUrl

	Write-Output "Function AD Registraton"
	createAAD -functionName $functionName	
	write-host "AD creation complete"
	

	# KEY VAULT SECRETS
	Write-Host "Reading secrets from $appsSharedKvName"
	$secrets = az keyvault secret list --vault-name $appsSharedKvName --output json
	$jsonsecrets = $secrets | ConvertFrom-Json
	$kvSecretNameClientId = $applicationPrefix + "-" + $environmentNameprefix.ToLower() + "-client-id"

	if(!($jsonsecrets | where {$_.id.endswith("/$kvSecretNameClientId") })) {	
		Write-Host "Writing secret $kvSecretNameClientId to $global:aadAppClientId"
		az keyvault secret set --name $kvSecretNameClientId --vault-name $appsSharedKvName --value $global:aadAppClientId
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

	Set-FunctionAppSetting -functionName $functionName -settingName "CacheExpiryTimeInMinutes" -settingValue "30"

	Set-FunctionAppSetting -functionName $functionName -settingName "APPINSIGHTS_INSTRUMENTATIONKEY" -settingValue $appInsightsInstrumentationKey

	Set-FunctionAppSetting -functionName $functionName -settingName "tenantid" -settingValue $tenantId

	Set-FunctionAppSetting -functionName $functionName -settingName "OpenIdConfigurationEndPoint" -settingValue "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"

	Set-FunctionAppSetting -functionName $functionName -settingName "ValidIssuers" -settingValue "https://login.microsoftonline.com/$tenantId/v2.0,https://sts.windows.net/$tenantId/"

	Set-FunctionAppSetting -functionName $functionName -settingName "FunctionName" -settingValue "$functionName"

	Set-FunctionAppSetting -functionName $functionName -settingName "audience" -settingValue "https://$functionName.azurewebsites.net"

	Set-FunctionAppSetting -functionName $functionName -settingName "UserPreferenceApplicationName" -settingValue $userPreferenceApplicationName

	Set-FunctionAppSetting -functionName $functionName -settingName "UserPreferenceApplicationRole" -settingValue $userPreferenceApplicationRole

	Set-FunctionAppSetting -functionName $functionName -settingName "BEASBaseUrl" -settingValue $beasBaseUrl


	

	# Set Function Cors and Credentials Support
	

	Write-Host "Assigning Function App MSI"
	$funcMsi = az webapp identity assign --resource-group $resourceGroupName --name $functionName

	$funcMsiJson = $funcMSI | ConvertFrom-Json

	$params = "--name",$kvName,"--object-id",$funcMsiJson.principalid,"--secret-permissions","get"

	az keyvault set-policy @params

	

	Write-Host "Enable AAD Authentication on Function App"
	az webapp auth update  --resource-group "$resourceGroupName" --name "$functionName" --enabled true --action "AllowAnonymous" --aad-allowed-token-audiences "https://$functionName.azurewebsites.net" "https://$functionName.azurewebsites.net/.auth/login/aad/callback" --aad-client-id "$global:aadAppClientId" --aad-client-secret "$global:aadAppClientSecret" --aad-token-issuer-url "https://sts.windows.net/$tenantId/" --allowed-external-redirect-urls "$webAppDefaultUrl" "$loginRedirectUrl"

	#Write-Host "Add permission to Sign-in and read user profile"
	#az ad app permission add --id $global:aadAppClientId --api 00000002-0000-0000-c000-000000000000 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope

	#az ad app permission grant --id $global:aadAppClientId --api 00000002-0000-0000-c000-000000000000 
		
	#az ad app permission admin-consent --id $global:aadAppClientId 
	

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
	$adGroupName = $projectPrefix.ToLower() + "-" + $applicationShortNamePrefix.ToLower() + "-group-" + $environmentNameprefix.ToLower();
	$adGroup = ''
	$adGroup = az ad group list --display-name $adGroupName
	$adGroupJson = $adGroup | ConvertFrom-Json

	if (!$adGroupJson)
	{
	Write-Host "creating ad group"
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

	$dbServerName = $projectPrefix.ToLower() + "-" + $applicationShortNamePrefix.ToLower() + "-sqlsvr-" + $environmentNameprefix.ToLower();
	$dbName =  $applicationShortNamePrefix.ToLower() + "-sqldbmi-" + $environmentNameprefix.ToLower();

	$sqlServer = Get-AzureRmSqlServer -ServerName $dbServerName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
	if(!$sqlServer)
	{
		Write-Output "Sql Server resource does not exist.";
		exit
	}

	# SQL SERVER DATABASE
	$sqlServerDatabase = Get-AzureRmSqlDatabase -DatabaseName $dbName -ServerName $dbServerName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
	if(!$sqlServerDatabase)
	{
		Write-Output "Sql Database does not exist.";
		exit
	}
	$sqlADAdminList = az sql server ad-admin list --server $dbServerName --resource-group $resourceGroupName
	$sqlADAdminListJson = $sqlADAdminList | ConvertFrom-Json
	
	$adminGroupName = $applicationShortNamePrefix.ToLower()+"-group-"+$environmentNameprefix.ToLower()+"-admin"
	$adminGroupJson = az ad group show --group $adminGroupName
	$adminGroup =$adminGroupJson | ConvertFrom-Json
	$existsInGroup = az ad group member check --group $adminGroupName --member-id $funcMsiJson.principalid
	$existsInGroupJson = $existsInGroup | ConvertFrom-Json
	
	Write-Host "admin group is $adminGroup" 
	if ($existsInGroupJson.value -eq $false)
	{
		az ad group member add --group $adminGroup.objectId --member-id  $funcMsiJson.principalid
	}

	if (!($sqlADAdminListJson | Where {$_.sid -eq $adminGroup.objectId}))
	{
		az sql server ad-admin create --resource-group $resourceGroupName --server-name $dbServerName --display-name $adminGroupName --object-id $adminGroup.objectId
	}

	az webapp config connection-string set --resource-group $resourceGroupName --name $functionName --settings ROUserPrefConnectionString="Server=tcp:$dbServerName.database.windows.net,1433;Database=$dbName;" --connection-string-type SQLServer
	az webapp config connection-string set --resource-group $resourceGroupName --name $functionName --settings RWUserPrefConnectionString="Server=tcp:$dbServerName.database.windows.net,1433;Database=$dbName;" --connection-string-type SQLServer
	
	Write-Host "Setup Front Door"
	az extension add --name front-door
		if($deployFrontDoor.ToLower() -eq "true" -Or $environmentNamePrefix.ToLower() -eq "prd"){
			$fdEnv = "prod"
			if($environmentNamePrefix.ToLower() -ne "prd")
			{
				$fdEnv = "nonprod"
			}

			$rgName = "apps-common-shared-services-rg-uks-"+ $fdEnv.ToLower()
			$frontDoorName = "brit-front-door-"+$fdEnv
			$lbName ="user-preference-lb-"+ $environmentNamePrefix.ToLower()
			$hbName = "user-preference-hb-"+ $environmentNamePrefix.ToLower()
			$forwardPath = "/api/userpreference/v1"
			$bePoolName = "user-preference-"+ $environmentNamePrefix.ToLower()
			$routingRule ="user-preference-rule-"+ $environmentNamePrefix.ToLower()
		
			az network front-door load-balancing create --front-door-name "$frontDoorName" --name $lbName --resource-group "$rgName" --sample-size "2" --successful-samples-required "2" 
			az network front-door probe create --front-door-name "$frontDoorName" --interval "255" --name $hbName --path "$forwardPath/HealthCheck" --resource-group "$rgName" --protocol "Https" --probeMethod "Get"
			az network front-door backend-pool create --address "$frontDoorName.azurefd.net" --front-door-name "$frontDoorName" --load-balancing $lbName --name "$bePoolName" --probe $hbName --resource-group "$rgName"
			az network front-door backend-pool backend add --address "$functionName.azurewebsites.net" --front-door-name "$frontDoorName" --pool-name $bePoolName --resource-group "$rgName" --backend-host-header "$functionName.azurewebsites.net"
			az network front-door backend-pool backend remove --front-door-name "$frontDoorName" --index "1" --pool-name "$bePoolName" --resource-group "$rgName"

			az network front-door routing-rule create --front-door-name "$frontDoorName" --frontend-endpoints "$frontDoorName" --name "$routingRule" --resource-group "$rgName" --route-type "Forward" --accepted-protocols "Http" "Https" --backend-pool "$bePoolName" --caching "Disabled" --patterns "/$functionName/*" --custom-forwarding-path "$forwardPath"
			Write-Host "Setup for Front Door complete"     
		}
		else{
			Write-Host "Setup for Front Door skipped"   
		}

	Write-Host "App Created" -ForegroundColor Green
	
	}
	Catch
	{
		$ErrorMessage = $_.Exception.Message

		Write-Host "Error: " + $ErrorMessage
	}
}

function createAAD(){
	param([string]$functionName)
	write-host $functionName
	$params = "--output","json","--display-name",$functionName
	$funcAdAppList = az ad app list @params
	$funcAdAppListJson = $funcAdAppList | ConvertFrom-Json

	$functionUrl = "https://" + $functionName + ".azurewebsites.net"

	if($funcAdAppListJson.Length -lt 1) {

		$functionReplyUrl = $functionUrl + "/.auth/login/aad/callback"

		Write-Host "Create AAD entry for application $functionName"
		$funcAdApp = az ad app create --output "json" --display-name "$functionName" --identifier-uris $functionUrl --reply-urls "$functionReplyUrl" "$webAppDefaultUrl" "$loginRedirectUrl" --homepage $functionUrl --oauth2-allow-implicit-flow "true"

		# Update Authentication to AD for Function
		Write-Host "Enabling AAD Authentication within $functionName"
		$aadSecret = [system.web.security.membership]::GeneratePassword(10,0)

		$funcAdAppJson = $funcAdApp | ConvertFrom-Json

		$global:aadAppClientId = $funcAdAppJson.appId
	
		$issuerUrl = "https://sts.windows.net/" + $tenantId
		$params = "-g",$resourceGroupName,"-n",$functionName,"--enabled","true","--action","AllowAnonymous","--aad-allowed-token-audiences",$functionReplyUrl,"--aad-client-id",$funcAdAppJson.appId,"--aad-client-secret",$aadSecret,"--aad-token-issuer-url",$issuerUrl,"--token-store","true"
		$funcAuth = az webapp auth update @params

		#$appSettingAuthConnectionString = "RunAs=App;AppId="+$funcAdAppJson.appId+";TenantId=$tenantId;AppKey=$aadSecret"
	}
	else
	{
		$global:aadAppClientId = $funcAdAppListJson[0].appId
	}
}

Write-Host "Creating app for user-preference-uks" -ForegroundColor Green
SetupSettings -locationAbbrev "uks" 



