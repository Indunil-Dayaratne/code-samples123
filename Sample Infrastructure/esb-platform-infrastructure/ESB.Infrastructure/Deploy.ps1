# This script requires:
#    Subscription created
#    Application Registration to be available and referenced as kvObjectId

param(
	[Parameter(Mandatory=$True)]
	[string]
	$subscriptionId,

	[Parameter(Mandatory=$True)]
	[string]
	$environmentNamePrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$deploymentName,

	[Parameter(Mandatory=$True)]
	[string]
	$ESBApplicationRegistrationId,

	[string]
	$resourceGroupLocation = "UK South",

	[Parameter(Mandatory=$True)]
	[string]
	$resourceNumber
)

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ','_'), '3.0.0')
} catch { }

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3


# General parameters

$tenantId = "8cee18df-5e2a-4664-8d07-0566ffea6dcd";
$location = $resourceGroupLocation;

$resourceGroupName = "RG-" + $environmentNameprefix.ToUpper() + "-ESB-UKS-01";

# Tags
$tagProjectCode = "G31";
$tagProjectBillingCycleEnd = (Get-date).AddMonths(12).ToString("D");

# Service Bus parameters
$sbNamespaceName = $environmentNamePrefix + "-esb-uks-svcbus";

# Key Vault parameters
$kvName = $environmentNamePrefix + "-esb-uks-kv";
$kvSkuName = "Standard";
$kvEnableVaultForDeployment = $TRUE;
$kvEnableVaultForDiskEncryption = $TRUE;
$kvEnabledForTemplateDeployment = $TRUE;

# Key Vault ESB Access parameters
$kvObjectId = $ESBApplicationRegistrationId #"a0e7b831-891f-4872-acb6-6d0e340b2164" ;  #Object ID of the ESB App Registration that has access to Key Vault
$kvKeysPermissions = ConvertFrom-Json -InputObject "[]";
$kvSecretsPermissions = ConvertFrom-Json -InputObject "['list','get']";

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "application_insights.json"))

if(Test-Path $templateFile) {
	get-location;
	Write-Host "Found application_insights.json ARM template file: " + $templateFile;
}
else {
	get-location;
	Write-Host "Can't find application_insights.json ARM template file: " + $templateFile;
	exit;
}

# Application Insights
[string[]]$applications = "beas2","dmsloader","eclipseloader","eclipsemapper","esb","keyvaultcredentials","webconinterface";
$appLocation = "weur";

for ($app=0;$app -lt $applications.length; $app++) {
	$appName = $applications[$app];
	$applicationName = $environmentNameprefix+"-" +$appName+"-"+$appLocation+"-appins";
	Write-Host "-------------------------------------------------";
	Write-Host "Create Application Insights: " $applicationName;
	New-AzureRmResourceGroupDeployment  -Mode Incremental `
										-ResourceGroupName $resourceGroupName `
										-TemplateFile $templateFile `
										-appName $applicationName									
	$details = Get-AzureRmResource -Name $applicationName -ResourceType "Microsoft.Insights/components" -ResourceGroupName $resourceGroupName
	$ikey = $details.Properties.InstrumentationKey
	Write-Host "-";
	Write-Host "-------------------------------------------------";
	Write-Host $applicationName ": Instrumentation Key = " $ikey;
	Write-Host "-------------------------------------------------";
	Write-Host "-";
}	


Write-Host "Create ESB SB Namespace: " $sbNamespaceName;
# Create service bus namespace...
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "ServiceBusDeploy-Namespace.json"))

New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile  $templateFile `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -serviceBusSku Standard;

# Topics
Write-Host "-------------------------------------------------";
Write-Host "Create ESB SB Topics"
# This topic broadcasts policy data from eclipse
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "ServiceBusDeploy-Topic.json"))

$sbTopicName = "eclipse-policy-out";
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusNamespaceName $sbNamespaceName `
    -serviceBusTopicName $sbTopicName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# Subscription
$sbTopicSubscriptionName = "peerreviewsystem";
New-AzureRmServiceBusSubscription `
    -ResourceGroup $resourceGroupName `
    -NamespaceName $sbNamespaceName `
    -TopicName $sbTopicName `
    -SubscriptionName $sbTopicSubscriptionName;

# This topic broadcasts policy data from velocity
$sbTopicName = "velocity-policy-out";
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusNamespaceName $sbNamespaceName `
    -serviceBusTopicName $sbTopicName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# Subscription
$sbTopicSubscriptionName = "peerreviewsystem";
New-AzureRmServiceBusSubscription `
    -ResourceGroup $resourceGroupName `
    -NamespaceName $sbNamespaceName `
    -TopicName $sbTopicName `
    -SubscriptionName $sbTopicSubscriptionName;
	
# This topic broadcasts document data from DMS
$sbTopicName = "dms-document-out";
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusNamespaceName $sbNamespaceName `
    -serviceBusTopicName $sbTopicName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

$sbTopicName = "dms-ocr-out";
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusNamespaceName $sbNamespaceName `
    -serviceBusTopicName $sbTopicName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# Subscription
$sbTopicSubscriptionName = "ocrservice";
New-AzureRmServiceBusSubscription `
    -ResourceGroup $resourceGroupName `
    -NamespaceName $sbNamespaceName `
    -TopicName $sbTopicName `
    -SubscriptionName $sbTopicSubscriptionName;

# Add Queues
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "ServiceBusDeploy-Queue.json"))

# This queue is the inbound queue for Eclipse policy data
$sbQueueName = "eclipse-policy-in";
Write-Host "-------------------------------------------------";
Write-Host "Create ESB SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# This queue is the inbound queue for Peer Review Work Item data
$sbQueueName = "prs-work-in";
Write-Host "-------------------------------------------------";
Write-Host "Create PRS SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# This queue is the inbound queue documents into DMS
$sbQueueName = "dms-document-in";
Write-Host "-------------------------------------------------";
Write-Host "Create DMS-Document-in SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# This queue is the inbound queue for SDC Document data
$sbQueueName = "sdc-document-in";
Write-Host "-------------------------------------------------";
Write-Host "Create SDC-Document-in SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# This queue is the inbound queue for SDC Eclipse Mapper for Document data
$sbQueueName = "sdceclipse-document-in";
Write-Host "-------------------------------------------------";
Write-Host "Create SDCEclipse-Document-in SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# This queue is the inbound queue for DMS OCR data
$sbQueueName = "dms-ocr-in";
Write-Host "-------------------------------------------------";
Write-Host "Create dms-ocr-in SB Queue: " $sbQueueName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -serviceBusQueueName $sbQueueName `
    -serviceBusNamespaceName $sbNamespaceName `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;

# Add Key Vault
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "KeyVaultDeploy.json"))

Write-Host "-------------------------------------------------";
Write-Host "Create ESB Key Vault: " $kvName;
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName  `
    -TemplateFile $templateFile `
    -keyVaultName $kvName `
    -tenantId $tenantId `
    -objectId $kvObjectId `
    -keysPermissions $kvKeysPermissions `
    -secretsPermissions $kvSecretsPermissions `
    -skuName $kvSkuName `
    -enableVaultForDeployment $kvEnableVaultForDeployment `
    -enableVaultForDiskEncryption $kvEnableVaultForDiskEncryption `
    -enabledForTemplateDeployment $kvEnabledForTemplateDeployment `
    -tagProjectCode $tagProjectCode `
    -tagProjectBillingCycleEnd $tagProjectBillingCycleEnd `
    -location $location;
	
# Add Storage
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "blobstorage.json"))

$storeName = $environmentNameprefix + "esbstore";
Write-Host "-------------------------------------------------";
Write-Host "Create ESB Storage: " $storeName;

Get-AzureRmStorageAccount -Name $storeName -ErrorVariable ev -ErrorAction SilentlyContinue -ResourceGroupName $resourceGroupName

if($ev) {
	New-AzureRmStorageAccount `
		-ResourceGroupName $resourceGroupName `
		-Name $storeName `
		-Location $location `
		-SkuName Standard_LRS `
		-Kind Storage;
}

Write-Host "- - - - - - - - - - - - - - - - - - - - -";
Write-Host "Create ESB Blob Containers in " $storeName;
$storagekey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storeName;
$context = New-AzureStorageContext -StorageAccountName $storeName -StorageAccountKey $storagekey.Value[0] -Protocol Http;

Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourceGroupName -Name $storeName;

$containerName = "eclipse-policy-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "eclipse-policy-out"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}
	
$containerName = "velocity-policy-out" 
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "prs-work-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "dms-document-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "dms-document-out"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName  -Context $context;
}

$containerName = "sdc-document-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "sdceclipse-document-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "dms-ocr-in"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}

$containerName = "dms-ocr-out"
Get-AzureStorageContainer -Name $containerName -ErrorVariable ev -ErrorAction SilentlyContinue -Context $context
if($ev) {
	New-AzureStorageContainer -Name $containerName -Context $context;
}
