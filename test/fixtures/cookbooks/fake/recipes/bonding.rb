case node['platform_family']
when 'rhel', 'fedora'
  int5 = 'eth5'
  int6 = 'eth6'

  # RHEL/CentOS 7+
  if node['platform_version'].to_i > 6
    int5 = 'enp0s5'
    int6 = 'enp0s6'
  end

  network_interface int5 do
    bootproto 'none'
    bond_master 'bond0'
  end

  network_interface int6 do
    bootproto 'none'
    bond_master 'bond0'
  end

  network_interface 'bond0' do
    bootproto 'static'
    address '12.12.12.10'
    netmask '255.255.255.0'
    bond_mode 'mode=1 miimon=100'
  end
when 'debian'
  network_interface 'bond0' do
    bootproto 'static'
    address '12.12.12.10'
    netmask '255.255.255.0'
    bond_slaves ['eth5', 'eth6']
    bond_mode '0'
  end

  network_interface 'eth5' do
    bootproto 'manual'
    bond_master 'bond0'
  end

  network_interface 'eth6' do
    bootproto 'manual'
    bond_master 'bond0'
  end
end
