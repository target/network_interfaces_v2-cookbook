network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.13'
  netmask '255.255.255.0'
  hw_address '00-25-B5-5B-00-25'
  gateway '10.12.10.1'
  netbios false
  post_up 'sleep 1'
  dns ['14.13.13.13', '14.13.13.12']
end

# Add an interface config using platform specific provider
win_network_interface 'eth2' do
  hw_address '00-25-B5-5B-00-27'
  dns ['14.13.13.13', '14.13.13.12']
  ddns false
  dns_domain 'test.it.com'
  netbios true
end

int_index = node['network']['interfaces'].select { |_i, d| d['instance']['net_connection_id'] == 'Ethernet 4' }.keys.first
index = node['network']['interfaces'][int_index]['configuration']['index']

network_interface 'Ethernet 4' do
  index index
  bootproto 'static'
  address node['network']['interfaces'][int_index]['configuration']['ip_address'].first
  netmask node['network']['interfaces'][int_index]['configuration']['ip_subnet'].first
end
