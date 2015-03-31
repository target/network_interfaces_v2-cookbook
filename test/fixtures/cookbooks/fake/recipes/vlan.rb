case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth2' do
    vlan true
  end
when 'debian'
  debian_network_interface 'eth2' do
    vlan_dev 'eth0'
  end
when 'windows'
  win_network_interface 'eth2' do
    index 8
    vlan 12
  end
end
