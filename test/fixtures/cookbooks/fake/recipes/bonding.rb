int5 = 'eth5'
int6 = 'eth6'

# RHEL/CentOS 7+ or Ubuntu 16.04+
if (%w(rhel fedora).include?(node['platform_family']) && node['platform_version'].to_i > 6) ||
   (%w(debian ubuntu).include?(node['platform_family']) && node['platform_version'] >= '16.04')
  int5 = 'enp0s5'
  int6 = 'enp0s6'
end

case node['platform_family']
when 'rhel', 'fedora'
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
    bond_slaves [int5, int6]
    bond_mode '0'
  end

  network_interface int5 do
    bootproto 'manual'
    bond_master 'bond0'
  end

  network_interface int6 do
    bootproto 'manual'
    bond_master 'bond0'
  end
end
