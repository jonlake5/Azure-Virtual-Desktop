param (
    [object]$WebhookData
)


$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$vmResourceGroupName = $inputData.vmResourceGroupName ? $inputData.vmResourceGroupName : $resourceGroupName
$hostPoolResourceGroupName = $inputData.hostPoolResourceGroupName ? $inputData.hostPoolResourceGroupName : $resourceGroupName
$hostPoolName = $inputData.hostPoolName
$vmName = $inputData.vmName
$accountID = Get-AutomationVariable -Name "accountId"
$null = Connect-AzAccount -Identity -AccountId $accountID

write-output "Getting Registration Token (or creating if one doesn't exist)"
$regToken = Get-AzWvdHostPoolRegistrationToken -ResourceGroupName $hostPoolResourceGroupname -HostPoolName $hostPoolName
    
if ($null -eq $regToken.Token) {
    write-output "Generating a new Registration Token"
    # $hostPool = Get-AzWvdHostPool -ResourceGroupName $resourceGroupName -HostPoolName $hostPoolName
    $expirationTime = (Get-Date).AddHours(1.5).ToUniversalTime() | Get-Date -Format "yyyy-MM-dd HH:mm"
    $regToken = New-AzWvdRegistrationInfo -ResourceGroupName $hostPoolResourceGroupName -HostPoolName $hostPoolName -ExpirationTime $expirationTime
    # start-sleep -seconds 5
    if ($null -eq $regToken.Token) {
        write-error "There was an error creating a registration token. This operation will not complete successfully."
        throw "Reg Token Not Created"
    }
}
$registrationToken = $regToken.Token

if ($null -eq $registrationToken) {
    throw "Unable to retrieve the registration token. Exiting."
}

$configUrl = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip"
$configFunction = "Configuration.ps1\AddSessionHost"

write-output "Adding host $vmName to host pool $hostPoolName"
Set-AzVMExtension `
    -ResourceGroupName $vmResourceGroupName `
    -VMName $vmName `
    -Name "DSC" `
    -Publisher "Microsoft.Powershell" `
    -ExtensionType "DSC" `
    -TypeHandlerVersion "2.26" `
    -Settings @{
    ModulesUrl            = $configUrl
    ConfigurationFunction = $configFunction
    Properties            = @{
        HostPoolName = $hostPoolName
    }
} `
    -ProtectedSettings @{
    Properties = @{
        registrationInfoToken = $registrationToken
    }
}