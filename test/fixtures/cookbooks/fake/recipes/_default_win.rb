network_interface 'Ethernet' do
  index 10
  bootproto 'static'
  address '10.0.2.15'
  netmask '255.255.255.0'
  gateway '10.0.2.2'
  dns ['4.2.2.4']
  reload false
end

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
