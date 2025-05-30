param (
    [object]$WebhookData
)


$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$accountID = $inputData.accountID
$vmName = $inputData.vmName
$domainName = $inputData.domainName
$ouPath = $inputData.ouPath
$user = $inputData.user
$password = $inputData.password

$null = Connect-AzAccount -Identity -AccountId $accountID



Set-AzVMExtension `
    -ResourceGroupName $resourceGroupName `
    -VMName $vmName `
    -Name "domain-Join" `
    -Publisher "Microsoft.Compute" `
    -ExtensionType "JsonADDomainExtension" `
    -TypeHandlerVersion "1.3" `
    -Settings @{
    Name    = $domainName
    OUPath  = $ouPath
    User    = $user
    Restart = $true
    Options = "3"    
} `
    -ProtectedSettings @{
    Password = $password
}