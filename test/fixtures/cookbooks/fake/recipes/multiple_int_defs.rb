network_interface 'eth0_inet4' do
  device 'eth0'
  bootproto 'static' if node['platform_family'] == 'debian'
  address '10.12.10.11'
  gateway node['network']['default_gateway']
  netmask '255.255.255.0'
  post_up 'sleep 1'
end

network_interface 'eth0_inet6' do
  ipv6 true
  device 'eth0'
  bootproto 'static'
  address 'FE80::0202:B3FF:FE1E:8329'
  gateway 'FE80::0202:B3FF:FE1E:0'
  netmask '64'
  post_up 'sleep 1'
end
