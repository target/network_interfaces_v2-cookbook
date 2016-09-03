network_interface 'ovsbr0' do
  bootproto 'none'
  devicetype 'ovs'
  hotplug false
  arpcheck false
  ipv6init false
  nm_controlled false
  ovsdhcpinterfaces ['enp0s5']
  ovsbootproto 'dhcp'
  type 'OVSBridge'
  userctl false
end
network_interface 'enp0s5' do
  bootproto 'none'
  type 'OVSPort'
  ipv6init false
  devicetype 'ovs'
  ovs_bridge 'ovsbr0'
end
# interfaces as string, not array of string
network_interface 'ovsbr1' do
  bootproto 'none'
  devicetype 'ovs'
  hotplug false
  arpcheck false
  ipv6init false
  nm_controlled false
  ovsdhcpinterfaces 'enp0s6'
  ovsbootproto 'dhcp'
  type 'OVSBridge'
  userctl false
end
network_interface 'enp0s6' do
  bootproto 'none'
  type 'OVSPort'
  ipv6init false
  devicetype 'ovs'
  ovs_bridge 'ovsbr1'
end
