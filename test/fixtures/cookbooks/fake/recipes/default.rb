# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

# Add additional interface configs
network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.11' if  %w(rhel fedora).include? node['platform_family']
  address '10.12.10.12' if  node['platform_family'] == 'debian'
  netmask '255.255.255.0'
  gateway node['network']['default_gateway']
  not_if { node['os'] == 'windows' }
end

# Add an interface config using platform specific provider
rhel_network_interface 'eth2' if %w(rhel fedora).include? node['platform_family']
debian_network_interface 'eth2' if %w(debian).include? node['platform_family']

if node['os'] == 'windows'
  win_network_interface 'eth1' do
    hw_address '00-25-B5-5B-00-25'
    bootproto 'static'
    address '10.12.10.13'
    netmask '255.255.255.0'
    gateway '10.12.10.1'
  end

  win_network_interface 'eth2' do
    hw_address '00-25-B5-5B-00-27'
  end
end
