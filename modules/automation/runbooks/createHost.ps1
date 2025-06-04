param (
    [object]$WebhookData
)


$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$galleryImage = $inputData.galleryImage
$hostPoolName = $inputData.hostPoolName
$vNetName = $inputData.vNetName
$subnetName = $inputData.subnetName
$accountID = $inputData.accountID
$hostPrefix = $inputData.hostPrefix
$vmSize = $inputData.vmSize
$location = $inputData.location
#New below to auto join domain
$domainName = $inputData.domainName
$ouPath = $inputData.ouPath
$user = $inputData.user
$vaultName = $inputData.vaultName
$secretName = $inputData.secretName
$maintenanceConfigName = $inputData.maintenanceConfigName

$null = Connect-AzAccount -Identity -AccountId $accountID


$galleryName, $imageDefinition, $imageVersion = $galleryImage.split('/')


## Get the host pool so we can get the VMs and determine next name
import-module az.compute -verbose
$sessionHosts = Get-AzWvdSessionHost -HostPoolName $hostPoolName -ResourceGroupName $resourceGroupName
if ($null -eq $sessionHosts -and $null -eq $hostPrefix) {
    write-error "The value for hostPrefix was not set and there are no session hosts to model the hostname after. Exiting"
    exit 1
}
if ($null -ne $sessionHosts -and $null -ne $hostPrefix) {
    write-warning "Hostprefix was set but there are also session hosts in the host pool. The provided value from hostprefix will be overriden by determining the host prefix based off of existing session host names"
}

$hostNumbers = @()

if ($sessionHosts) {

    foreach ($sessionHost in $sessionHosts.name) {
        $hostNumber = $sessionHost.split(".")[0].split('-')[-1]
        $hostNumbers += [int32]$hostNumber
        $hostName = $sessionHost.split('/')[-1].split(".")[0]
    }
    $nextHostNumber = ($hostNumbers | Sort-Object )[-1] + 1
    write-output "Next host number is $nextHostNumber"
    
    write-output "Hostname is $hostName"
    $hostPrefix = [Regex]::Match($hostName, "(.+)-\d+$").Groups[1].Value
}
else {
    $nextHostNumber = 0
}
$vmName = @($hostPrefix, [string]$nextHostNumber) | join-string -Separator "-"
if ($vmName.Length -gt 15) {
    write-error "The generated VM Name ($vmName) is longer than 15 characters and will not be created."
    exit 1
}


## Get the base image to use
$image = Get-azgalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDefinition #-GalleryImageVersionName $imageVersion
write-output "Image is $($image.id)"
## Get the subnet and vNet to put the host it
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$nicName = "$($vmName)-nic"
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nicName -SubnetId $subnet.Id -Force


# Create the VM
$username = "avdadmin"
$password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object { [char]$_ })
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $securePassword)


$vmConfig = New-AzVMConfig `
    -VMName $vmName `
    -VMSize $vmSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
    Set-AzVMSourceImage -Id $image.Id  | `
    Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -VM $vmConfig  
    

write-output "VM is $($vmName)"
write-output "Username is $($username)"
write-output "Joining the domain"

$password = (Get-AzKeyVaultSecret -vaultName $vaultName -Name $secretName).secretValue | ConvertFrom-SecureString -AsPlainText
[securestring]$secStringPassword = ConvertTo-SecureString $password -AsPlainText -Force
[pscredential]$credential = New-Object System.Management.Automation.PSCredential ($user, $secStringPassword)

Set-AzVMADDomainExtension -Name "domain-join" -DomainName $domainName -OUPath $ouPath -VMName $vMName -Credential $credential -ResourceGroupName $ResourceGroupName -JoinOption 0x00000003 -Restart -Verbose

if ($maintenancePlan) {
    $configAssignmentName = "$vmName-$maintenance"
    $maintenanceConfig = Get-AzMaintenanceConfiguration -ResourceGroupName $resourceGroupName -Name $maintenanceConfigName
    New-AzConfigurationAssignment `
        -ResourceGroupName $resourceGroup `
        -Location $location `
        -ResourceName $vmName `
        -ResourceType "VirtualMachines" `
        -ProviderName "Microsoft.Compute" `
        -ConfigurationAssignmentName $configAssignmentName `
        -MaintenanceConfigurationId $maintenanceConfig.Id
}