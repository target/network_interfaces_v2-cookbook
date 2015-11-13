case node['platform_family']
when 'rhel', 'fedora'
  int8 = 'eth8'

  # RHEL/CentOS 7+
  int8 = 'enp0s8' if node['platform_version'].to_i > 6

  rhel_network_interface int8 do
    bootproto 'none'
  end

  rhel_network_interface "#{int8}.12" do
    bootproto 'static'
    address '12.12.12.12'
    netmask '255.255.255.0'
    vlan true
  end
when 'debian'
  debian_network_interface 'eth8' do
    bootproto 'manual'
  end

  debian_network_interface 'eth8.12' do
    bootproto 'static'
    address '12.12.12.12'
    netmask '255.255.255.0'
    vlan 'eth8'
  end
when 'windows'
  win_network_interface 'vlan12' do
    hw_address '00-25-B5-5B-00-35'
    bootproto 'static'
    address '12.12.12.14'
    netmask '255.255.255.0'
    dns ['4.2.2.4', '4.2.2.8']
    vlan 12
  end
end
