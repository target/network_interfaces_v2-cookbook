# Make sure we don't wipe out enp0s3
network_interface 'enp0s3'

# Add additional interface configs
network_interface 'enp0s4' do
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
