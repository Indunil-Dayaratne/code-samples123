[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]
    $resourceGroupName,

    [Parameter(Mandatory=$True)]
    [string]
    $serviceName,

    [Parameter(Mandatory=$True)]
    [string]
    $serviceUrl,

    [Parameter(Mandatory=$True)]
    [string]
    $specificationUrl,

    [Parameter(Mandatory=$True)]
    [string]
    $apiName,

    [Parameter(Mandatory=$True)]
    [string]
    $apiPath
)

$subscriptionId = $env:ARM_SUBSCRIPTION_ID
$tenantId = $env:ARM_TENANT_ID
$clientId = $env:ARM_CLIENT_ID
$secret = $env:ARM_CLIENT_SECRET

az login --service-principal --username $clientId --password $secret --tenant $tenantId

az account set --subscription $subscriptionId

az apim api import --resource-group $resourceGroupName --service-name $serviceName --path $apiPath --api-id $apiName --specification-format "OpenApi" --specification-url $specificationUrl --service-url $serviceUrl

az apim api update --service-name $serviceName -g $resourceGroupName --api-id $apiName --display-name $apiName
