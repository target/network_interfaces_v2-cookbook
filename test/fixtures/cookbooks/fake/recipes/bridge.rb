int7 = 'eth7'

# RHEL/CentOS 7+
if (%w(rhel fedora).include?(node['platform_family']) && node['platform_version'].to_i > 6) ||
   (%w(debian ubuntu).include?(node['platform_family']) && node['platform_version'] >= '16.04')
  int7 = 'enp0s7'
end

case node['platform_family']
when 'rhel', 'fedora'
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
    bridge_ports [int7]
    bridge_stp false
  end

  network_interface int7 do
    bootproto 'manual'
  end
end
