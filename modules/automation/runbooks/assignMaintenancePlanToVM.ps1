param (
    [object]$WebhookData
)

$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$maintenanceConfigResourceGroupName = $inputData.maintenanceConfigName ? $inputData.maintenanceConfigName : $resourceGroupName
$maintenanceConfigName = $inputData.maintenanceConfigName
$location = $inputData.location
$vmName = $inputData.vmName
$accountID = Get-AutomationVariable -Name "accountId"
$null = Connect-AzAccount -Identity -AccountId $accountId

$configAssignmentName = "$vmName-$maintenanceConfigName"
$maintenanceConfig = Get-AzMaintenanceConfiguration -ResourceGroupName $maintenanceConfigResourceGroupName -Name $maintenanceConfigName
if ($null -eq $maintenanceConfig) {
    throw "The Maintenance Config $maintenanceConfig in Resource Group $maintenanceConfigResourceGroupName was not found. Exiting"
}
New-AzConfigurationAssignment `
    -ResourceGroupName $maintenanceConfigResourceGroupName `
    -Location $location `
    -ResourceName $vmName `
    -ResourceType "VirtualMachines" `
    -ProviderName "Microsoft.Compute" `
    -ConfigurationAssignmentName $configAssignmentName `
    -MaintenanceConfigurationId $maintenanceConfig.Id
