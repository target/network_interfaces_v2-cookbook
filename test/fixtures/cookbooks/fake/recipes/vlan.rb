case node['platform_family']
when 'rhel', 'fedora'
  int0 = 'eth0'
  int2 = 'eth2'

  # RHEL/CentOS 7+
  if node['platform_version'].to_i > 6
    int0 = 'enp0s3'
    int2 = 'enp0s9'
  end

  network_interface int0

  rhel_network_interface int2 do
    bootproto 'none'
  end

  rhel_network_interface "#{int2}.12" do
    bootproto 'static'
    address '12.12.12.12'
    netmask '255.255.255.0'
    vlan true
  end
when 'debian'
  network_interface 'eth0'

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
    hw_address '00-25-B5-5B-00-29'
    bootproto 'static'
    address '12.12.12.14'
    netmask '255.255.255.0'
    dns ['4.2.2.4', '4.2.2.8']
    vlan 12
  end
end
