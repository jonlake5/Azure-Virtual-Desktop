param (
    [object]$WebhookData
)

$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$vmResourceGroupName = $inputData.vmResourceGroupName ? $inputData.vmResourceGroupName : $resourceGroupName
$subscriptionId = $inputData.subscriptionId
$locationFilter = $inputData.locationFilter
$accountID = Get-AutomationVariable -Name "accountId"

# Connect to Azure using managed identity
$null = Connect-AzAccount -Identity -AccountId $accountID

# Set the context
Set-AzContext -SubscriptionId $SubscriptionId

$resourceGroup = Get-AzResourceGroup -Name $vmResourceGroupName
# Get the policy assignment
$assignments = Get-AzPolicyAssignment -Scope $resourceGroup.ResourceId -ErrorAction Stop
if ($null -eq $assignments) {
    throw "Policy assignment '$PolicyAssignmentName' not found."
}

foreach ($assignment in $assignments) {
    $remediationAssignmentName = "remediation_$($assignment.Name.replace(' ',''))_$(Get-Date -Format 'yyyyMMddHHmm')"
    if ($null -in @($assignment.Id, $resourceGroup.ResourceGroupName)) {
        throw "AssignmentID or ResourceGroup were not found`n`n  Resource Group: $($resourceGroup.ResourceGroupName)`n`n  AssignmentId: $($assignment.Id)"
    }
    $remediationParams = @{
        Name               = $remediationAssignmentName
        PolicyAssignmentId = $assignment.Id
        ResourceGroupName  = $resourceGroup.ResourceGroupName
        LocationFilter     = $locationFilter
    }
    Write-Output "Creating remediation task '$remediationAssignmentName' for policy Assignment '$($assignment.Name)'..."
    $remediationTask = Start-AzPolicyRemediation @remediationParams
    if ($null -eq $remediationTask) {
        write-output "Unable to create remediation task."
    }
    else {
    }   Write-Output "Remediation task created successfully."
}