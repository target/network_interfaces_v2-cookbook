int9 = 'eth9'
if node['platform_version'] >= '16.04'
  int9 = 'enp0s9'
end

network_interface "#{int9}_inet4" do
  device int9
  bootproto 'static' if node['platform_family'] == 'debian'
  address '10.12.10.19'
  gateway node['network']['default_gateway']
  metric 101
  netmask '255.255.255.0'
  post_up 'sleep 1'
end

network_interface "#{int9}_inet6" do
  ipv6 true
  device int9
  bootproto 'static'
  address 'fe80::202:b3ff:fe1e:8329'
  gateway 'fe80::0202:b3ff:fe1e:0'
  netmask '64'
  post_up 'sleep 1'
end
