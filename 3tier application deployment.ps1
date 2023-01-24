# Connect to Azure subscription
Connect-AzAccount
Connect-AzAccount -Subscription 'cddf40cb-4cc1-4144-b855-a55070f66106'

# Create resource group
$resourceGroup = New-AzResourceGroup -Name "KPMGinterview" -Location "EastUS"

# Create virtual network and subnet
$vnet = New-AzVirtualNetwork -Name "vnet-3tier" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -AddressPrefix "10.0.0.0/16"
$subnet1 = Add-AzVirtualNetworkSubnetConfig -Name "appsubnet1" -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet -ResourceId $vnet.id
$subnet2 = Add-AzVirtualNetworkSubnetConfig -Name "websubnet1" -AddressPrefix "10.0.2.0/24" -VirtualNetwork $vnet
$subnet3 = Add-AzVirtualNetworkSubnetConfig -Name "dbsubnet1" -AddressPrefix "10.0.3.0/24" -VirtualNetwork $vnet


# Create virtual machines for each tier
$vm1 = New-AzVM -Name "webServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "appsubnet1" -AddressPrefix "10.0.1.0/24" -PublicIpAddressName "webServerIp" -OpenPorts 80
$vm2 = New-AzVM -Name "appServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "websubnet1" -AddressPrefix "10.0.2.0/24" -PublicIpAddressName "appServerIp" -OpenPorts 8080
$vm3 = New-AzVM -Name "dbServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "dbsubnet1" -AddressPrefix "10.0.3.0/24" -PublicIpAddressName "dbServerIp" -OpenPorts 1433

# Create availability sets
$avSet1 = New-AzAvailabilitySet -Name "webServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2
$avSet2 = New-AzAvailabilitySet -Name "appServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2
$avSet3 = New-AzAvailabilitySet -Name "dbServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2

# Add virtual machines to availability sets
Add-AzVmToAvailabilitySet -VM $vm1 -AvailabilitySet $avSet1
Add-AzVmToAvailabilitySet -VM $vm2 -AvailabilitySet $avSet2
Add-AzVmToAvailabilitySet -VM $vm3 -AvailabilitySet $avSet3

# Create load balancer
$lb = New-AzLoadBalancer -Name "myLoadBalancer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -FrontendIpConfigurationName "lbFrontendIp" -BackendPoolName "lbBackendPool"

# Create load balancer rules
$lbRule1 = New-AzLoadBalancerRuleConfig -Name "httpRule" -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[
