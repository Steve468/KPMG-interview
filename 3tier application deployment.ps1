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

# Create availability sets
$avSet1 = New-AzAvailabilitySet -Name "webServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2 -Sku Aligned
$avSet2 = New-AzAvailabilitySet -Name "appServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2 -Sku Aligned
$avSet3 = New-AzAvailabilitySet -Name "dbServerAvSet" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2 -Sku Aligned


# Create virtual machines for each tier
$vm1 = new-AzVM -Name "webServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "appsubnet1" -AddressPrefix "10.0.1.0/24" -PublicIpAddressName "webServerIp" -OpenPorts 80 -AvailabilitySetName $avSet1.Name
$vm2 = New-AzVM -Name "appServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "websubnet1" -AddressPrefix "10.0.2.0/24" -PublicIpAddressName "appServerIp" -OpenPorts 8080 -AvailabilitySetName $avSet2.Name
$vm3 = New-AzVM -Name "dbServer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -VirtualNetworkName $vnet.Name -SubnetName "dbsubnet1" -AddressPrefix "10.0.3.0/24" -PublicIpAddressName "dbServerIp" -OpenPorts 1433 -AvailabilitySetName $avSet3.Name


$publicip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup.ResourceGroupName -Name "lb-ip" -Location $resourceGroup.Location -AllocationMethod "Dynamic"
$frontend = New-AzLoadBalancerFrontendIpConfig -Name "MyFrontEnd" -PublicIpAddress $publicip

$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "MyBackendAddPoolConfig02"
$probe = New-AzLoadBalancerProbeConfig -Name "MyProbe" -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -ProbeThreshold 2 -RequestPath "healthcheck.aspx"
$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name "MyinboundNatRule1" -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP
$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name "MyinboundNatRule2" -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 3391 -BackendPort 3392
$lbrule = New-AzLoadBalancerRuleConfig -Name "MyLBruleName" -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIP
$lb = New-AzLoadBalancer -Name "MyLoadBalancer" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe -InboundNatRule $inboundNatRule1,$inboundNatRule2 -LoadBalancingRule $lbrule

