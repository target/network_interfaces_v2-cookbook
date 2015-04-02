# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

case node['platform_family']
when 'rhel', 'fedora'
  rhel_network_interface 'eth1' do
    bootproto 'none'
    bond_master 'bond0'
  end

  rhel_network_interface 'eth2' do
    bootproto 'none'
    bond_master 'bond0'
  end

  rhel_network_interface 'bond0' do
    bond_mode 'mode=1 miimon=100'
  end
when 'debian'
  debian_network_interface 'bond0' do
    bootproto 'static'
    address '12.12.12.10'
    netmask '255.255.255.0'
    bond_slaves ['eth1', 'eth2']
    bond_mode '0'
  end

  network_interface 'eth1' do
    bootproto 'manual'
    bond_master 'bond0'
  end

  network_interface 'eth2' do
    bootproto 'manual'
    bond_master 'bond0'
  end
end
