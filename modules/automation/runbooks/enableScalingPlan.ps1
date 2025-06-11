param (
    [object]$WebhookData
)

Write-Output "Logging in as user assigned managed Identity"

$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$scalingPlanName = $inputData.scalingPlanName
$hostPoolName = $inputData.hostPoolName
# $accountID = $inputData.accountID
$accountID = Get-AutomationVariable -Name "accountId"

$null = Connect-AzAccount -Identity -AccountId $accountID

write-output "Starting Automation"

$subscriptionId = (Get-AzContext).Subscription.Id
# Build the full ARM path for the host pool
$hostPoolArmPath = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/hostpools/$hostPoolName"

# Get all scaling plans in the resource group
$scalingPlan = Get-AzWvdScalingPlan -ResourceGroupName $resourceGroupName -name $scalingPlanName
if ($null -eq $scalingPlan) {
    throw "Unable to get scaling plan. Exiting."
}


if (($false -eq $($scalingPlan.HostPoolReference.ScalingPlanEnabled) -and $scalingPlan.HostPoolReference.HostPoolArmPath -eq $hostPoolArmPath)) {
    write-output "Turning on Scaling Plan for Host Pool $($hostPoolName)"
    #Get All References and remove the one related to our change
    $origRefs = $scalingPlan.HostPoolReference
    $newRefs = $origRefs |  Where-Object { $_.HostPoolArmPath -ne $hostPoolArmPath }
    $allNewRefs = @()
    foreach ($ref in $newRefs) {
        $allNewRefs += $ref
    }
    #Add the original ref back in
    $origRef = @{
        'HostPoolArmPath'    = $hostPoolArmPath;
        'ScalingPlanEnabled' = $true;
    }
    $allNewRefs += $origRef
    write-output "All new references listed below"
    foreach ($ref in $allNewRefs) {
        write-output "Reference: `n$($ref.HostPoolArmPath)`n$($ref.ScalingPlanEnabled)"
    }

    $null = Update-AzWvdScalingPlan `
        -ResourceGroupName $resourceGroupName `
        -Name $scalingPlan.Name `
        -HostPoolReference $allnewRefs
}
elseif ($true -eq $($scalingPlan.HostPoolReference.ScalingPlanEnabled)) {
    Write-Output "The scaling plan is already enabled"
}
else {
    Write-Output "The host pool was not found in the scaling plan"
}

