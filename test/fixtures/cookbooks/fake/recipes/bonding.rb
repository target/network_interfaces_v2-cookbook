case node['platform_family']
when 'rhel', 'fedora'
  int0 = 'eth0'
  int1 = 'eth1'
  int2 = 'eth2'

  # RHEL/CentOS 7+
  if node['platform_version'].to_i > 6
    int0 = 'enp0s3'
    int1 = 'enp0s8'
    int2 = 'enp0s9'
  end

  network_interface int0

  network_interface int1 do
    bootproto 'none'
    bond_master 'bond0'
  end

  network_interface int2 do
    bootproto 'none'
    bond_master 'bond0'
  end

  network_interface 'bond0' do
    bond_mode 'mode=1 miimon=100'
  end
when 'debian'
  network_interface 'eth0'

  network_interface 'bond0' do
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
