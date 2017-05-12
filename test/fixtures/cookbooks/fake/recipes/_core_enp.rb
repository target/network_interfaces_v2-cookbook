# Add additional interface configs
network_interface 'enp0s4' do
  bootproto 'none' unless node['platform_family'] == 'debian'
  bootproto 'static' if node['platform_family'] == 'debian'
  address '10.12.10.11'
  gateway node['network']['default_gateway']
  metric 100
  netmask '255.255.255.0'
  post_up 'sleep 1'
  hotplug true
  unless node['platform_family'] == 'debian'
    arpcheck true
    devicetype 'ovs'
    onboot true
    prefix 24
    type 'OVSBridge'
    zone 'trusted'
  end
end
