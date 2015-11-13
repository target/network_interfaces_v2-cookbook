case node['platform_family']
when 'rhel', 'fedora'

  int0 = 'eth0'
  int1 = 'eth1'

  # RHEL/CentOS 7+
  if node['platform_version'].to_i > 6
    int0 = 'enp0s3'
    int1 = 'enp0s8'
  end

  network_interface int0

  rhel_network_interface int1 do
    bootproto 'none'
    bridge_device 'br0'
  end

  network_interface 'br0' do
    bootproto 'static'
    address '13.13.13.10'
    netmask '255.255.255.0'
  end
when 'debian'
  network_interface 'eth0'

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
