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

$null = Connect-AzAccount -Identity -AccountId $accountID


$galleryName, $imageDefinition, $imageVersion = $galleryImage.split('/')


## Get the host pool so we can get the VMs and determine next name
import-module az.compute -verbose
$sessionHosts = Get-AzWvdSessionHost -HostPoolName $hostPoolName -ResourceGroupName $resourceGroupName
$hostNumbers = @()

if ($sessionHosts) {

    foreach ($sessionHost in $sessionHosts.name) {
        $hostNumber = $sessionHost.split('-')[-1]
        $hostNumbers += [int32]$hostNumber
    
    }
    $nextHostNumber = ($hostNumbers | Sort-Object )[-1] + 1
}
else {
    $nextHostNumber = 0
}
$vmName = @($hostPrefix, [string]$nextHostNumber) | join-string -Separator "-"



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
write-output "Password is $($password)"