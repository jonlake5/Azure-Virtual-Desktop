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
$vaultName = $inputData.vaultName
$secretName = $inputData.secretName

$null = Connect-AzAccount -Identity -AccountId $accountID

$password = (Get-AzKeyVaultSecret -vaultName $vaultName -Name $secretName).secretValue | ConvertFrom-SecureString -AsPlainText

if ($null -eq $password) {
    throw "Unable to retrieve the domain join password."
}

write-output "Domain Name is $domainName"
write-output "ouPath is $ouPath"
write-output "user is $user"

[securestring]$secStringPassword = ConvertTo-SecureString $password -AsPlainText -Force
[pscredential]$credential = New-Object System.Management.Automation.PSCredential ($user, $secStringPassword)

Set-AzVMADDomainExtension -Name "domain-join" -DomainName $domainName -OUPath $ouPath -VMName $vMName -Credential $credential -ResourceGroupName $ResourceGroupName -JoinOption 0x00000003 -Restart -Verbose
