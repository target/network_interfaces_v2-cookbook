network_interface 'eth0'

# Add additional interface configs
network_interface 'eth4' do
  bootproto 'static'
  address '10.12.10.12' if node['platform_family'] == 'debian'
  netmask '255.255.255.0'
  gateway node['network']['default_gateway']
  post_up 'sleep 1'
end
