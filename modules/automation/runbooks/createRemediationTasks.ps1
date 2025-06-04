param (
    [object]$WebhookData
)

$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$subscriptionId = $inputData.subscriptionId
$locationFilter = $inputData.locationFilter
$accountId = $inputData.accountId

# Connect to Azure using managed identity
$null = Connect-AzAccount -Identity -AccountId $accountID

# Set the context
Set-AzContext -SubscriptionId $SubscriptionId

$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName
# Get the policy assignment
$assignments = Get-AzPolicyAssignment -Scope $resourceGroup.ResourceId -ErrorAction Stop
if ($null -eq $assignments) {
    Write-Error "Policy assignment '$PolicyAssignmentName' not found."
    return
}

foreach ($assignment in $assignments) {
    $remediationAssignmentName = "remediation_$($assignment.Name.replace(' ',''))_$(Get-Date -Format 'yyyyMMddHHmm')"
    $remediationParams = @{
        Name               = $remediationAssignmentName
        PolicyAssignmentId = $assignment.Id
        ResourceGroupName  = $resourceGroup.ResourceGroupName
        LocationFilter     = $locationFilter
    }
    Write-Output "Creating remediation task '$remediationAssignmentName' for policy Assignment '$($assignment.Name)'..."
    $remediationParams
    # Start-AzPolicyRemediation @remediationParams
    Write-Output "Remediation task created successfully."
}


