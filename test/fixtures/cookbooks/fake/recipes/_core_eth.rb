# Make sure we don't wipe out eth0
network_interface 'eth0'

# Add additional interface configs
network_interface 'eth4' do
  bootproto 'none' unless node['platform_family'] == 'debian'
  bootproto 'static' if node['platform_family'] == 'debian'
  address '10.12.10.11'
  gateway node['network']['default_gateway']
  netmask '255.255.255.0'
  post_up 'sleep 1'
  hotplug true
  unless node['platform_family'] == 'debian'
    devicetype 'ovs'
    onboot true
    prefix 24
    type 'OVSBridge'
    defroute false
  end
end
