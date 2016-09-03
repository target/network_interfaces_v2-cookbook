network_interface 'ovsbr0' do
  bootproto 'none'
  devicetype 'ovs'
  hotplug false
  arpcheck false
  ipv6init false
  nm_controlled false
  ovsdhcpinterfaces ['eth5']
  ovsbootproto 'dhcp'
  type 'OVSBridge'
  userctl false
end
network_interface 'eth5' do
  bootproto 'none'
  type 'OVSPort'
  ipv6init false
  devicetype 'ovs'
  ovs_bridge 'ovsbr0'
end
# as String, not Array of String
network_interface 'ovsbr1' do
  bootproto 'none'
  devicetype 'ovs'
  hotplug false
  arpcheck false
  ipv6init false
  nm_controlled false
  ovsdhcpinterfaces 'eth6'
  ovsbootproto 'dhcp'
  type 'OVSBridge'
  userctl false
end
network_interface 'eth6' do
  bootproto 'none'
  type 'OVSPort'
  ipv6init false
  devicetype 'ovs'
  ovs_bridge 'ovsbr1'
end
