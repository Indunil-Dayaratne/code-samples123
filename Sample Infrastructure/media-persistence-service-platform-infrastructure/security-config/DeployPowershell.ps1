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
	$beasUrl,

	[Parameter(Mandatory=$False)]
	[string]
	$deployFrontDoor = "False"
)

# Main Variables

# Resource Group Name
$locationAbbrev = "uks";

$global:aadAppClientId = ""
$global:aadAppClientSecret = [system.web.security.membership]::GeneratePassword(10,0)

function GetOrCreateKeyVault($name,$resourceGroupName,$location,$tenantId,$subscriptionId,$keyPrefix) {
	$keyVault = Get-AzKeyVault -Name $name -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
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

function Check-FunctionAppSettings {
	param([string]$functionName,[string]$numberOfAppSettings)

	$params = "--output","json","--resource-group",$resourceGroupName,"--name",$functionName
	$settingList = az functionapp config appsettings list @params
	$settingListJson = $settingList | ConvertFrom-Json
	if(!($settingListJson.Length -eq $numberOfAppSettings))
	{
		return $False
	}

	return $True
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

function UpgradeAzureAccount {
	param (
		[string]$resourceGroupName, [string]$storageName
	)

	$account = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName

	if($account.Sku.Name -eq "Standard_ZRS"){
		Write-Host "Upgrading storage account - $storageName";
		Set-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageName -AccessTier Hot -Force -SkuName Standard_GZRS
	}
}

function SetupSettings(){
	param([string]$locationAbbrev)
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
	$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
	$resourceGroupName = $projectPrefix.ToLower() + "-" + $applicationPrefix.ToLower() + "-rg-" + $locationAbbrev.ToLower() + "-" + $environmentNameprefix.ToLower();

$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
az login --service-principal @params

Set-AzContext -SubscriptionId $subscriptionId;

Write-Host "Azure Context set to '$subscriptionId'" 

Try{
	$ErrorActionPreference = 'Stop'
	Set-StrictMode -Version 3

	# Function Variables
	$functionName =  $applicationPrefix.ToLower() + "-func-" + $environmentNameprefix.ToLower();
	$functionStorageName =  $applicationPrefixShortName.ToLower() + "funcstor" + $locationAbbrev + $environmentNameprefix.ToLower();
	$appInsightName = $applicationPrefix.ToLower() + "-appins-" + $environmentNameprefix.ToLower();
	$blobContainer = $applicationPrefixShortName.ToLower() + "containuks" + $environmentNameprefix.ToLower();
	$cosmosContainer = "media-container-" + $environmentNameprefix.ToLower();

	# Key Vault Variables
	if($applicationPrefix.Length -lt 13)
	{
		$kvNamePrefix = $applicationPrefix
	}
	else{
		$kvNamePrefix = "$applicationPrefix".ToLower().Substring(0,13)
	}
	$kvName = "$kvNamePrefix".ToLower().Substring(0,13) + "-kv-" + $environmentNameprefix.ToLower();
	$functionKvName = $functionName + "-appid"

	# RESOURCE GROUP
	$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction Stop 
	if(!$resourceGroup)
	{
		Write-Host "Resource group '$resourceGroupName' does not exist.";
		exit
	}

	# APP INSIGHTS
	$appInsights = Get-AzApplicationInsights -ResourceGroupName $resourceGroupName -Name $appInsightName -ErrorAction Stop
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

	UpgradeAzureAccount -resourceGroupName $resourceGroupName -storageName $functionStorageName
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
	#$funcApp = Get-AzResource -Name $functionName -ResourceGroupName $resourceGroupName -ErrorAction Continue

	$funcApp = Get-FunctionApp -functionName $functionName

	if(!$funcApp)
	{
		Write-Output "FunctionApp resource does not exist.";
		exit
	
	}	


	
	$cosmosDBAccountName = "apps-common-cosmos-nonprod"
	$commonRGName = "apps-common-shared-services-rg-uks-nonprod"
	# Set Function Cors and Credentials Support

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
				$cosmosDBAccountName = "apps-common-cosmos-prod"
				$commonRGName = "apps-common-shared-services-rg-uks-prod"
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

	Write-Output "Function AD Registraton"
	if($locationAbbrev -eq "uks")
		{
			createAAD -functionName $functionName	
			write-host "AD creation complete"
		}

	# FUNC SETTINGS
	$funcKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $functionStorageName
	$accountKey =  $funcKeys | Where-Object { $_.KeyName -eq "key1"} | Select Value
	$funcStorageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=" +$functionStorageName + ";AccountKey=" + $accountKey.Value
	#$funcAppSettings = @{}
    
	#$funcAppSettingsExist = Check-FunctionAppSettings -functionName $functionName -numberOfAppSettings 12

	$funcAppSettings = Get-FunctionAppSettings -functionName $functionName 

	$appInsightsInstrumentationKey = $appInsights.InstrumentationKey;

	Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsDashboard" -settingValue $funcStorageAccountConnectionString

	Set-FunctionAppSetting -functionName $functionName -settingName "AzureWebJobsStorage" -settingValue $funcStorageAccountConnectionString

	Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_EXTENSION_VERSION" -settingValue "-1"

	Set-FunctionAppSetting -functionName $functionName -settingName "FUNCTIONS_WORKER_RUNTIME" -settingValue "dotnet"

	Set-FunctionAppSetting -functionName $functionName -settingName "MSGRAPH_RESOURCEID" -settingValue "https://graph.microsoft.com"

	Set-FunctionAppSetting -functionName $functionName -settingName "KEYVAULT_RESOURCEID" -settingValue "https://$kvName.vault.azure.net/secrets/"

	Set-FunctionAppSetting -functionName $functionName -settingName "CacheExpiryTimeInMinutes" -settingValue "30"

	Set-FunctionAppSetting -functionName $functionName -settingName "APPINSIGHTS_INSTRUMENTATIONKEY" -settingValue $appInsightsInstrumentationKey

	Set-FunctionAppSetting -functionName $functionName -settingName "tenantid" -settingValue $tenantId

	Set-FunctionAppSetting -functionName $functionName -settingName "OpenIdConfigurationEndPoint" -settingValue "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"

	Set-FunctionAppSetting -functionName $functionName -settingName "ValidIssuers" -settingValue "https://login.microsoftonline.com/$tenantId/v2.0,https://sts.windows.net/$tenantId/"

	Set-FunctionAppSetting -functionName $functionName -settingName "FunctionName" -settingValue "$functionName"

	Set-FunctionAppSetting -functionName $functionName -settingName "audience" -settingValue "https://$functionName.azurewebsites.net"

	Set-FunctionAppSetting -functionName $functionName -settingName "BEASBaseUrl" -settingValue $beasUrl

	Set-FunctionAppSetting -functionName $functionName -settingName "AzureBlobStorageConnectionStringKey" -settingValue "storage-conection-string"

	Set-FunctionAppSetting -functionName $functionName -settingName "AzureBlobStorageContainer" -settingValue $blobContainer	
	
	Set-FunctionAppSetting -functionName $functionName -settingName "CosmosDatabaseName" -settingValue "shared"

	Set-FunctionAppSetting -functionName $functionName -settingName "CosmosContainer" -settingValue $cosmosContainer	

	Write-Host "Assigning Function App MSI"
	$funcMsi = az webapp identity assign --resource-group $resourceGroupName --name $functionName

	$funcMsiJson = $funcMSI | ConvertFrom-Json

	$params = "--name",$kvName,"--object-id",$funcMsiJson.principalid,"--secret-permissions","get"

	az keyvault set-policy @params
	if($global:aadAppClientId -ne ""){
	$loginRedirectUrl = $webAppDefaultUrl + "/Home/LoginRedirect"
	
	$redirectUrls = "$webAppDefaultUrl" + " " + "$loginRedirectUrl"
		Write-Host $redirectUrls

	write-host "client id is $global:aadAppClientId"
		az webapp auth update  --resource-group $resourceGroupName --name $functionName --enabled true --action AllowAnonymous --aad-allowed-token-audiences "https://$functionName.azurewebsites.net" "https://$functionName.azurewebsites.net/.auth/login/aad/callback" --aad-client-id "$global:aadAppClientId" --aad-client-secret "$global:aadAppClientSecret" --aad-token-issuer-url "https://sts.windows.net/$tenantId/" --allowed-external-redirect-urls "$webAppDefaultUrl" "$loginRedirectUrl"
	}

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
		$lbName ="media-persistence-lb-"+ $environmentNamePrefix.ToLower()
		$hbName = "media-persistence-hb-"+ $environmentNamePrefix.ToLower()
		$forwardPath = "/api/MediaPersistenceService/v1"
		$bePoolName = "media-persistence-"+ $environmentNamePrefix.ToLower()
		$routingRule ="media-persistence-rule-"+ $environmentNamePrefix.ToLower()

		$fdSettings = az network front-door load-balancing list --front-door-name "$frontDoorName" --resource-group "$rgName"
		$fdSettingsJson = $fdSettings | ConvertFrom-Json

		$fdSettingSelected = $fdSettingsJson | Where-Object { $_.name -eq "$lbName"} | Select-Object

		if (!$fdSettingSelected) {
			az network front-door load-balancing create --front-door-name "$frontDoorName" --name $lbName --resource-group "$rgName" --sample-size "2" --successful-samples-required "2"
			az network front-door probe create --front-door-name "$frontDoorName" --interval "255" --name $hbName --path "$forwardPath/HealthCheck" --resource-group "$rgName" --protocol "Https" --probeMethod "Get"
			az network front-door backend-pool create --address "$frontDoorName.azurefd.net" --front-door-name "$frontDoorName" --load-balancing $lbName --name "$bePoolName" --probe $hbName --resource-group "$rgName"
			az network front-door backend-pool backend add --address "$functionName.azurewebsites.net" --front-door-name "$frontDoorName" --pool-name $bePoolName --resource-group "$rgName" --backend-host-header "$functionName.azurewebsites.net"
			az network front-door backend-pool backend remove --front-door-name "$frontDoorName" --index "1" --pool-name "$bePoolName" --resource-group "$rgName"

			az network front-door routing-rule create --front-door-name "$frontDoorName" --frontend-endpoints "$frontDoorName" --name "$routingRule" --resource-group "$rgName" --route-type "Forward" --accepted-protocols "Http" "Https" --backend-pool "$bePoolName" --caching "Disabled" --patterns "/$functionName/*" --custom-forwarding-path "$forwardPath"
		}
		
		Write-Host "Setup for Front Door complete"     
	}
	else{
		Write-Host "Setup for Front Door skipped"   
	}

	$cosmosAccount = az cosmosdb show --name $cosmosDBAccountName --resource-group $commonRGName

	$cosmosAccountJson = $cosmosAccount | ConvertFrom-Json

	$cosmosDocumentEndpoint = $cosmosAccountJson.documentEndpoint
	$cosmosDB = az cosmosdb database show --db-name "shared" --name $cosmosDBAccountName --resource-group-name $commonRGName

	$cosmosDBJson = $cosmosDB | ConvertFrom-Json

	Write-Host "CosmosDB Account Found. Shared Database id - " + $cosmosDBJson._rid

	$cosmosDBCollections = az cosmosdb collection list --db-name "shared" --name $cosmosDBAccountName --resource-group-name $commonRGName

	$cosmosDBCollectionsJson = $cosmosDBCollections | ConvertFrom-Json

	Write-Host $cosmosDBCollectionsJson.Length + " CosmosDB Collections Found."

	$mediaContainerName = "media-container-" + $environmentNamePrefix.ToLower()

	$mediaCollection =  $cosmosDBCollectionsJson | Where-Object { $_.id -eq $mediaContainerName } | Select $_

	Write-Host "CosmosDB Media Collection Found. Collection id - " + $mediaCollection._rid

	Set-FunctionAppSetting -functionName $functionName -settingName "MediaDBId" -settingValue $cosmosDBJson._rid

	Set-FunctionAppSetting -functionName $functionName -settingName "MediaCollId" -settingValue $mediaCollection._rid

	Set-FunctionAppSetting -functionName $functionName -settingName "MediaDBEndpoint" -settingValue $cosmosDocumentEndpoint

	Write-Host "App Created" -ForegroundColor Green

	
	}
	Catch
	{
		$ErrorMessage = $_.Exception.Message

		Write-Host "Error: "$ErrorMessage
	}
}
function createAAD(){
	param([string]$functionName)
	write-host $functionName
	$params = "--output","json","--display-name","$functionName"
	$funcAdAppList = az ad app list @params
	$funcAdAppListJson = $funcAdAppList | ConvertFrom-Json
	$functionUrl = "https://" + $functionName + ".azurewebsites.net"
	#$appSettingAuthConnectionString = ""
	
	$functionReplyUrl = $functionUrl + "/.auth/login/aad/callback"
	$loginRedirectUrl = $webAppDefaultUrl + "/Home/LoginRedirect"
	$issuerUrl = "https://sts.windows.net/" + $tenantId
	write-host "$funcAdAppListJson" $funcAdAppListJson.Length

	if($funcAdAppListJson.Length -lt 1) {
		write-host "creating new aad"
		Write-Host "Create AAD entry for application $functionName"
		$funcAdApp = az ad app create --output "json" --display-name "$functionName" --identifier-uris $functionUrl --reply-urls "$functionReplyUrl" "$webAppDefaultUrl" "$loginRedirectUrl" --homepage $functionUrl --oauth2-allow-implicit-flow "true"
		# Update Authentication to AD for Function
		Write-Host "Enabling AAD Authentication within $functionName"
		$funcAdAppJson = $funcAdApp | ConvertFrom-Json
		$global:aadAppClientId = $funcAdAppJson.appId
		write-host "client id is $global:aadAppClientId"
		$funcAuth = az webapp auth update -g $resourceGroupName -n $functionName --enabled "true" --action "AllowAnonymous" --aad-allowed-token-audiences "$functionReplyUrl" "$webAppDefaultUrl" "$loginRedirectUrl" --aad-client-id $funcAdAppJson.appId --aad-client-secret $global:aadAppClientSecret --aad-token-issuer-url $issuerUrl --token-store "true"
		#$appSettingAuthConnectionString = "RunAs=App;AppId="+$funcAdAppJson.appId+";TenantId=$tenantId;AppKey=$aadSecret"
	}
	else
	{
		$global:aadAppClientId = $funcAdAppListJson[0].appId
	}
}
Write-Host "Creating app for media-uks" -ForegroundColor Green
SetupSettings -locationAbbrev "uks" 



