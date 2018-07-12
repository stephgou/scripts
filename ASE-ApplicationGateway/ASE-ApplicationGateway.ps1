Param(  
    # Name of the subscription to use for azure cmdlets
    $subscriptionName = "[subscriptionName]",
    $subscriptionId = "[subscriptionId]",
    #Param�tres du Azure Ressource Group
	$deployTag = "ASE",
    $resourceGroupName = "XX-RG-" + $deployTag,
    $resourceGroupDeploymentName = $resourceGroupName+"-Deployed",
    $resourceLocation = "North Europe",
    $templateFile = "azuredeploy.json",    
    $templateParameterFile = "azuredeploy.parameters.json",
    $tagName = "Deploy Tag",
    $tagValue = $deployTag,
    $applicationGatewayName = "APS-AppGW"
    )

#region init
Set-PSDebug -Strict

cls
$d = get-date
Write-Host "Starting Deployment $d"

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "scriptFolder" $scriptFolder

set-location $scriptFolder
#endregion init

Login-AzureRmAccount -SubscriptionId $subscriptionId

# Resource group create
New-AzureRmResourceGroup `
	-Name $resourceGroupName `
	-Location $resourceLocation `
    -Tag @{Name=$tagName;Value=$tagValue} `
    -Verbose

# Resource group deploy

<#

New-AzureRmResourceGroupDeployment `
    -Name $resourceGroupDeploymentName `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "$scriptFolder\$templateFile" `
	-TemplateParameterFile "$scriptFolder\$templateParameterFile" `
    -Debug -Verbose -DeploymentDebugLogLevel All
Test-AzureRmResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "$scriptFolder\$templateFile" `
	-TemplateParameterFile "$scriptFolder\$templateParameterFile" `
    -Debug -Verbose


#>

New-AzureRmResourceGroupDeployment `
    -Name $resourceGroupDeploymentName `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "$scriptFolder\$templateFile" `
	-TemplateParameterFile "$scriptFolder\$templateParameterFile" `
    -Debug -Verbose -DeploymentDebugLogLevel All

$gw = Get-AzureRmApplicationGateway -Name $applicationGatewayName -ResourceGroupName $resourceGroupName


$d = get-date
Write-Host "Stopping Deployment $d"