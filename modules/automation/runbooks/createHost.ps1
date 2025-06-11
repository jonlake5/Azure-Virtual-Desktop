param (
    [object]$WebhookData
)


$inputData = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$resourceGroupName = $inputData.resourceGroupName
$galleryImage = $inputData.galleryImage
$hostPoolName = $inputData.hostPoolName
$vNetName = $inputData.vNetName
$subnetName = $inputData.subnetName
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
$joinType = $inputData.joinType
$vmName = $inputData.vmName

$accountID = Get-AutomationVariable -Name "accountId"
$null = Connect-AzAccount -Identity -AccountId $accountID


$galleryName, $imageDefinition, $imageVersion = $galleryImage.split('/')


## Get the host pool so we can get the VMs and determine next name

#determine the VM Name
if ($vmName -and ($vmName -notmatch '-\d+$')) {
    $vmName = "$vmName-1"
}
if (-not $vmName) {
    $sessionHosts = Get-AzWvdSessionHost -HostPoolName $hostPoolName -ResourceGroupName $resourceGroupName
    if ($null -eq $sessionHosts -and $null -eq $hostPrefix) {
        throw "The value for hostPrefix was not set and there are no session hosts to model the hostname after. Exiting"
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
        write-output "Existing hostname of host in pool is $hostName"
        $hostPrefix = [Regex]::Match($hostName, "(.+)-\d+$").Groups[1].Value
    }
    else {
        $nextHostNumber = 1
    }
    $vmName = @($hostPrefix, [string]$nextHostNumber) | join-string -Separator "-" 
}


if ($vmName.Length -gt 15) {
    throw "The generated VM Name ($vmName) is longer than 15 characters and will not be created."
}


## Get the base image to use
$image = Get-azgalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDefinition #-GalleryImageVersionName $imageVersion
if ($null -eq $image) {
    throw "Unable to get the shared image ($imageDefinition) from the gallery $galleryName"
}

write-output "Image is $($image.id)"
## Get the subnet and vNet to put the host it
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$nicName = "$($vmName)-nic"
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nicName -SubnetId $subnet.Id -Force

if ($null -eq $nic) {
    throw "Unable to create the NIC for the VM"
}

# Create the VM
Write-Output "Creating the VM Configuration"
$username = "avdadmin"
$password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object { [char]$_ })
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

$vmConfig = New-AzVMConfig `
    -VMName $vmName `
    -VMSize $vmSize `
    -IdentityType SystemAssigned | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
    Set-AzVMSourceImage -Id $image.Id  | `
    Add-AzVMNetworkInterface -Id $nic.Id
Write-Output "Creating the VM"
$vm = New-AzVM `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -VM $vmConfig  
    
if ($null -eq $vm) {
    throw "The VM was unable to be created. Exiting"
}

write-output "VM is $($vmName)"
write-output "Local Username is $($username)"
if ($joinType -eq "Entra") {
    write-output "Joining to Entra"
    $script = @'
dsregcmd.exe /join
'@

    $encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))

    # Install the AADJoinScript Custom Script Extension
    $null = Set-AzVMExtension -ResourceGroupName $resourceGroupName -Location $location -VMName $vmName `
        -Name "AADJoinScript" -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" `
        -TypeHandlerVersion "1.10" `
        -Settings @{ "commandToExecute" = "powershell -EncodedCommand $encodedScript" }

    # Poll until the extension completes
    $maxRetries = 30
    $retryInterval = 10 # seconds
    $attempt = 0

    do {
        Start-Sleep -Seconds $retryInterval
        $extensionStatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "AADJoinScript"
        $statusCode = $extensionStatus.ProvisioningState
        Write-Output "AADJoinScript extension status: $statusCode"

        if ($statusCode -like "*Succeed*") {
            break
        }
        write-host "This is attempt $attempt"
        $attempt++
    } while ($attempt -lt $maxRetries -and $statusCode -notlike "*Succeed*")

    if ($statusCode -notlike "*Succeed*") {
        throw "AADJoinScript failed or timed out after $($maxRetries * $retryInterval) seconds."
    }
    $aadJoinExtension = Set-AzVMExtension -ResourceGroupName $resourceGroupName -Location $location -VMName $vmName `
        -Name "AADLoginForWindows" -Publisher "Microsoft.Azure.ActiveDirectory" -ExtensionType "AADLoginForWindows" `
        -TypeHandlerVersion "1.0" -Settings @{mdmId = "0000000a-0000-0000-c000-000000000000" }

    if ($null -eq $aadJoinExtension) {
        Write-Warning "The VM was unable to be entra joined"
    }
}
if ($joinType -eq "AD") {   
    write-output "Joining the AD domain $domainName in OU $outPath"
    $password = (Get-AzKeyVaultSecret -vaultName $vaultName -Name $secretName).secretValue | ConvertFrom-SecureString -AsPlainText
    [securestring]$secStringPassword = ConvertTo-SecureString $password -AsPlainText -Force
    [pscredential]$credential = New-Object System.Management.Automation.PSCredential ($user, $secStringPassword)
    Set-AzVMADDomainExtension -Name "domain-join" -DomainName $domainName -OUPath $ouPath -VMName $vMName -Credential $credential -ResourceGroupName $ResourceGroupName -JoinOption 0x00000003 -Restart -Verbose 
}

if ($maintenancePlan) {
    Write-Output "Assigning Maintenance Plan $maintenanceConfigName to VM $vmName"
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