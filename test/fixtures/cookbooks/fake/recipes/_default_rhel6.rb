# Make sure we don't wipe out eth0
network_interface 'eth0'

# Add additional interface configs
network_interface 'eth4' do
  address '10.12.10.11'
  netmask '255.255.255.0'
  prefix 24
  gateway node['network']['default_gateway']
  # dns ['14.13.13.13', '14.13.13.12']
  onboot true
  bootproto 'none'
  type 'OVSBridge'
  devicetype 'ovs'
  post_up 'sleep 1'
end
