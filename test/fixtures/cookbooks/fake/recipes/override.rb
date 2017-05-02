case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth2' do
    address '12.12.12.12'
    network '12.12.12.0'
    netmask '255.255.255.0'
    broadcast '12.12.12.255'
    gateway '12.12.12.1'
    bootproto 'static'
    type 'IPsec'
    bond_master 'eth0'
    bond_mode 'test opts'
    mac_address '12-12-12-12-12-12'
    hw_address '13-13-13-13-13-13'
    bridge_device 'eth0'
    bridge_stp false
    mtu 1501
    nm_controlled true
    ipv6init false
    nozeroconf true
    userctl false
    peerdns true
    dns_domain 'example.domain.com'
  end
when 'debian'
  debian_network_interface 'eth2' do
    address '12.12.12.12'
    netmask '255.255.255.0'
    broadcast '12.12.12.255'
    gateway '12.12.12.1'
    bootproto 'static'
    ipv6 true
    bond_slaves ['eth0', 'eth1']
    bond_mode 'test mode'
    bridge_ports ['eth3', 'eth4']
    bridge_stp false
    mtu 1501
    pre_up ['1st pre up code', '2nd pre up code']
    up 'code for up'
    post_up 'post up it'
    pre_down 'pre down plz'
    down 'coming down'
    post_down 'im down'
    custom 'custom_attr' => 'custom_command',
           'abc' => '123'
  end
end

network_interface 'eth1' do
  address '12.12.12.12'
  bootproto 'static'
  netmask '255.255.255.0'
  broadcast '12.12.12.255'
  gateway '12.12.12.1'
  bond_mode 'test opts'
  bridge_stp false
  mtu 1501
end
