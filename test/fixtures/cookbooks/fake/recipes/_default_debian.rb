# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

# Add additional interface configs
network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.12' if node['platform_family'] == 'debian'
  netmask '255.255.255.0'
  gateway node['network']['default_gateway']
  post_up 'sleep 1'
end

# Add an interface config using platform specific provider
debian_network_interface 'eth2'
