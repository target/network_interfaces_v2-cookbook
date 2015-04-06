# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth2' do
    bootproto 'none'
  end

  rhel_network_interface 'eth2.12' do
    bootproto 'static'
    address '12.12.12.12'
    netmask '255.255.255.0'
    vlan true
  end
when 'debian'
  debian_network_interface 'eth2' do
    bootproto 'manual'
  end

  debian_network_interface 'eth2.12' do
    bootproto 'static'
    address '12.12.12.13'
    netmask '255.255.255.0'
    vlan 'eth2'
  end
when 'windows'
  win_network_interface 'eth2' do
    hw_address '00-25-B5-5B-00-25'
    bootproto 'static'
    address '12.12.12.14'
    netmask '255.255.255.0'
    vlan 12
  end
end
