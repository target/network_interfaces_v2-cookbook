case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth2' do
    bond_master 'eth0'
    bond_mode 'test opts'
  end
when 'debian'
  debian_network_interface 'eth2' do
    bond_slaves ['eth0', 'eth1']
    bond_mode 'test mode'
  end
end
