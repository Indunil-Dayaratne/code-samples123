#
# RunLocal.ps1
#
CLS
CD "C:\code\tfs\britgroupservices\EnterpriseServiceBus\ESB.Infrastructure";

# Login
#Connect-AzureRmAccount

$subscriptionId = "af11cc97-a355-47f1-af8d-0d9f4109274a";

Set-AzureRmContext -SubscriptionId $subscriptionId;

.\deploy.ps1   -environmentNamePrefix test2 `
				-deploymentName testdeployment `
				-subscriptionId $subscriptionId  `
				-ESBApplicationRegistrationId a0e7b831-891f-4872-acb6-6d0e340b2164;
