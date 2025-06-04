param (
    [object]$WebhookData
)

$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$maintenanceConfigName = $inputData.maintenanceConfigName
$location = $inputData.location
$vmName = $inputData.vmName
$maintenanceConfigName = $inputData.maintenanceConfigName
$accountId = $inputData.accountId

$null = Connect-AzAccount -Identity -AccountId $accountId

$configAssignmentName = "$vmName-$maintenanceConfigName"
$maintenanceConfig = Get-AzMaintenanceConfiguration -ResourceGroupName $resourceGroupName -Name $maintenanceConfigName
if ($null -eq $maintenanceConfig) {
    throw "The Maintenance Config $maintenanceConfig in Resource Group $resourceGroupName was not found. Exiting"
}
New-AzConfigurationAssignment `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -ResourceName $vmName `
    -ResourceType "VirtualMachines" `
    -ProviderName "Microsoft.Compute" `
    -ConfigurationAssignmentName $configAssignmentName `
    -MaintenanceConfigurationId $maintenanceConfig.Id
