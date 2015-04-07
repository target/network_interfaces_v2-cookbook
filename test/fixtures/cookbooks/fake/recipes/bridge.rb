# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth1' do
    bootproto 'none'
    bridge_device 'br0'
  end

  rhel_network_interface 'br0' do
    bootproto 'static'
    address '13.13.13.10'
    netmask '255.255.255.0'
  end
when 'debian'
  debian_network_interface 'br0' do
    bootproto 'static'
    address '13.13.13.11'
    netmask '255.255.255.0'
    bridge_ports ['eth1']
    bridge_stp false
  end

  network_interface 'eth1' do
    bootproto 'manual'
  end
end
