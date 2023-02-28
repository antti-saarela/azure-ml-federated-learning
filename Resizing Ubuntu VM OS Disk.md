```
$rg = "arc-ubuntu-vm_group"
$vmName = "arc-ubuntu-vm"
$vm = Get-AzureRmVM -ResourceGroupName $rg -Name $vmName
$vm.StorageProfile[0].OSDisk[0].DiskSizeGB = 256
Update-AzureRmVM –ResourceGroupName $rg -VM $vm
```
