case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth2' do
    vlan true
  end
when 'debian'
  debian_network_interface 'eth2' do
    vlan_dev 'eth0'
  end
end
