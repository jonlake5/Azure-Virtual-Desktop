param (
    [object]$WebhookData
)


$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$hostPoolName = $inputData.hostPoolName
$accountID = $inputData.accountID
$vmName = $inputData.vmName

$null = Connect-AzAccount -Identity -AccountId $accountID

function get-RegistrationKey {
    param (
        [string]$hostPoolName,
        [string]$resourceGroupName

    )
    $regToken = Get-AzWvdHostPoolRegistrationToken -ResourceGroupName $resourceGroupname -HostPoolName $hostPoolName
    if ($null -eq $regToken) {
        $hostPool = Get-AzWvdHostPool -ResourceGroupName $resourceGroupName -HostPoolName $hostPoolName
        $expirationTime = (Get-Date).AddHours(1)
        $regToken = New-RdsRegistrationInfo -HostPool $hostPool -ExpirationTime $expirationTime
    }
    return $regToken.Token
    
}

$registrationToken = get-registrationkey -hostPoolName $hostPoolName -resourceGroupName $resourceGroupName
$configUrl = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip"
$configFunction = "Configuration.ps1\AddSessionHost"


Set-AzVMExtension `
    -ResourceGroupName $resourceGroupName `
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