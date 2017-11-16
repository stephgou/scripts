Param(  
    # Name of the subscription to use for azure cmdlets
    $subscriptionName = "stephgou - External",
    $subscriptionId = "fb79eb46-411c-4097-86ba-801dca0ff5d5",
    
    #Paramètres du Azure Ressource Group
    $resourceGroupName = "SG-RG-NEO",
    $resourceGroupDeploymentName = "SG-NEO-SQLAO",
    $resourceLocation = "West Europe",
    $templateFile = "azuredeploy.json",
    $templateParameterFile = "azuredeploy.parameters.json"
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
#Login-AzureRmAccount -SubscriptionId $subscriptionId

# Resource group create
New-AzureRmResourceGroup `
	-Name $resourceGroupName `
	-Location $resourceLocation `
    -Verbose

# Resource group deploy
New-AzureRmResourceGroupDeployment `
    -Name $resourceGroupDeploymentName `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "$scriptFolder\$templateFile" `
	-TemplateParameterFile "$scriptFolder\$templateParameterFile" `
    -Debug -Verbose -DeploymentDebugLogLevel All

Get-AzureRmResourceGroupDeploymentOperation -DeploymentName $resourceGroupDeploymentName -ResourceGroupName $resourceGroupName # mandatory ? -ApiVersion 
Get-AzureRmLog -ResourceGroup $resourceGroupName -DetailedOutput

$d = get-date
Write-Host "Stopping Deployment $d"