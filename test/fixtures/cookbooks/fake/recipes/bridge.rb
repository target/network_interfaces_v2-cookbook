case node['platform_family']
when 'rhel', 'fedora'
  int7 = 'eth7'

  # RHEL/CentOS 7+
  int7 = 'enp0s7' if node['platform_version'].to_i > 6

  rhel_network_interface int7 do
    bootproto 'none'
    bridge_device 'br0'
  end

  network_interface 'br0' do
    bootproto 'static'
    address '13.13.13.10'
    netmask '255.255.255.0'
  end
when 'debian'
  debian_network_interface 'br0' do
    bootproto 'static'
    address '13.13.13.10'
    netmask '255.255.255.0'
    bridge_ports ['eth7']
    bridge_stp false
  end

  network_interface 'eth7' do
    bootproto 'manual'
  end
end
