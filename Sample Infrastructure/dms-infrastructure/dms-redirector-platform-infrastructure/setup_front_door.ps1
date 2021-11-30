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
	$applicationPrefix,

	[Parameter(Mandatory=$True)]
	[string]
	$spnName,

	[Parameter(Mandatory=$True)]
	[SecureString]
	$spnPassword,

	[Parameter(Mandatory=$False)]
	[string]
	$deployFrontDoor = "false"
)

if($deployFrontDoor.ToLower() -eq "true"){
	az extension add --name front-door
}

function Set-FrontDoor() {
	param([string]$appName, [string] $appAbbreviation, [string] $forwardPath, [string] $healthCheckPath)

	if($deployFrontDoor.ToLower() -eq "true"){
		$fdEnv = "prod"
		if($environmentNamePrefix.ToLower() -ne "prd")
		{
			$fdEnv = "nonprod"
		}

		$rgName = "apps-common-shared-services-rg-uks-$fdEnv"
		$frontDoorName = "brit-front-door-$fdEnv"
		$lbName ="dms-sponlineredirector-lb-"+ $appAbbreviation + "-" + $environmentNamePrefix.ToLower()
		$hbName = "dms-sponlineredirector-hb-"+ $appAbbreviation + "-" + $environmentNamePrefix.ToLower()		
		$bePoolName = "dms-sponlineredirector-"+ $appAbbreviation + "-" + $environmentNamePrefix.ToLower()
		$routingRule ="dms-sponlineredirector-rule-"+ $appAbbreviation + "-" + $environmentNamePrefix.ToLower()
		$patternPath = "dms-sponlineredirector-"+ $appAbbreviation + "-" + $environmentNamePrefix.ToLower()

		$fdSettings = az network front-door load-balancing list --front-door-name "$frontDoorName" --resource-group "$rgName"
		$fdSettingsJson = $fdSettings | ConvertFrom-Json

		$fdSettingSelected = $fdSettingsJson | Where-Object { $_.name -eq "$lbName"} | Select-Object

		if (!$fdSettingSelected) {
			az network front-door load-balancing create --front-door-name "$frontDoorName" --name $lbName --resource-group "$rgName" --sample-size "2" --successful-samples-required "2"
			az network front-door probe create --front-door-name "$frontDoorName" --interval "255" --name $hbName --path "$healthCheckPath" --resource-group "$rgName" --protocol "Https" --probeMethod "Get"
			az network front-door backend-pool create --address "$frontDoorName.azurefd.net" --front-door-name "$frontDoorName" --load-balancing $lbName --name "$bePoolName" --probe $hbName --resource-group "$rgName"
			az network front-door backend-pool backend add --address "$appName.azurewebsites.net" --front-door-name "$frontDoorName" --pool-name $bePoolName --resource-group "$rgName" --backend-host-header "$appName.azurewebsites.net"
			az network front-door backend-pool backend remove --front-door-name "$frontDoorName" --index "1" --pool-name "$bePoolName" --resource-group "$rgName"

			az network front-door routing-rule create --front-door-name "$frontDoorName" --frontend-endpoints "$frontDoorName" --name "$routingRule" --resource-group "$rgName" --route-type "Forward" --accepted-protocols "Http" "Https" --backend-pool "$bePoolName" --caching "Disabled" --patterns "/$patternPath/*" --custom-forwarding-path "$forwardPath"
		}
		else {
			$beSettings = az network front-door backend-pool backend list --front-door-name "$frontDoorName" --pool-name "$bePoolName" --resource-group "$rgName"

			$beSettingsJson = $beSettings | ConvertFrom-Json
			$beSelected = $beSettingsJson | Where-Object { $_.address -eq "$appName.azurewebsites.net"} | Select-Object

			if(!$beSelected)
			{
				az network front-door backend-pool backend add --address "$appName.azurewebsites.net" --front-door-name "$frontDoorName" --pool-name $bePoolName --resource-group "$rgName" --backend-host-header "$appName.azurewebsites.net"
			}
		}
		
		Write-Host "Setup for Front Door complete"     
	}
	else{
		Write-Host "Setup for Front Door skipped"   
	}	
}

function SetupSettings(){
	param([string]$locationAbbrev)
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($spnPassword)
	$unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

	$params = "--username",$spnName,"--password",$unsecurePassword,"--tenant",$tenantId
	az login --service-principal @params
	az account set --subscription $subscriptionId

	Write-Host "Azure Context set to '$subscriptionId'" 

	try{

		$ErrorActionPreference = 'Stop'
		Set-StrictMode -Version 3

		# Function Variables
		$webAppName =  $applicationPrefix.ToLower() + "-webapp-" + $locationAbbrev + "-" + $environmentNameprefix.ToLower();	

		Write-Host "Setup Front Door - Web App"

		Set-FrontDoor -appName $webAppName -appAbbreviation "web" -forwardPath "/" -healthCheckPath "/api/HealthCheck"
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
		Write-Host "Error: " + $ErrorMessage
	}
}

Write-Host "Creating FrontDoor for dms-sponlineredirector-$locationAbbrev" -ForegroundColor Green

SetupSettings -locationAbbrev "uks"
SetupSettings -locationAbbrev "ukw"
