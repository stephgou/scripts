# Move a VM using manage disk from A Subscriptionto B Subscription

$resourceGroupName = "<<resourceGroupName>>"
$vmName = "<<VM Name>>"
$subscriptionIdA = "<<subscription Id A>>"
$subscriptionIdB = "<<subscription Id B>>"
$storageAccountB = "<<storageAccount B>>"
$osDiskName = "<<OSDisk Name>>"
$storageAccountB = "<<storageAccountB>>"
$storageAccountBKey = "<<storageAccountKeyB>>"
$vhdUri = "https://$storageAccountB.blob.core.windows.net/vhds/$osDiskName.vhd" 
$location = "westeurope"
$storageType = "StandardLRS"
$subnetName = "mySubNet"
$vnetName = "myVnet"
$nicName = "myNicName"
$vmSize = "Standard_A2"

Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionIdA

#Step 0: Stop VM, Generalize and get access to OS Managed Disks underlying blob URL: #
Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force 
Set-AzureRmVm -ResourceGroupName $resourceGroupName -Name $vmName -Generalized

#Step 1: Copy the Managed Disk (as VHD file) to a storage account in the same subscription
$sas = Grant-AzureRmDiskAccess -ResourceGroupName $resourceGroupName -DiskName $osDiskName -DurationInSecond 3600 -Access Read 
$destContext = New-AzureStorageContext -StorageAccountName $storageAccountB -StorageAccountKey $storageAccountBKey 
Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer 'vhds' -DestContext $destContext -DestBlob "$osDiskName.vhd"

#Step 2: Create Managed Disk using the VHD file in another subscription
Select-AzureRmSubscription -SubscriptionId $subscriptionIdB
$storageAccountBId = "/subscriptions/$subscriptionIdB/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountB"

$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Import -SourceUri $vhdUri -DiskSizeGB 128
$osDisk = New-AzureRmDisk -DiskName $osDiskName -Disk $diskConfig -ResourceGroupName $resourceGroupName

#Step 3: Attached the OS Disk to a newly created VM
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -StorageAccountType $storageType -DiskSizeInGB 128 -CreateOption Attach -Windows

New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm