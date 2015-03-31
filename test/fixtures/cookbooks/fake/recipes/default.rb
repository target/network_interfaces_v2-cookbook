# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

# Add additional interface configs
network_interface 'eth1' unless node['os'] == 'windows'

# Add an interface config using platform specific provider
rhel_network_interface 'eth2' if %w(rhel fedora).include? node['platform_family']
debian_network_interface 'eth2' if %w(debian).include? node['platform_family']

if node['os'] == 'windows'
  win_network_interface 'eth1' do
    index 14
    bootproto 'static'
    address '10.12.10.11'
    netmask '255.255.255.0'
  end

  win_network_interface 'eth2' do
    hw_address '00-25-B5-5B-00-27'
  end
end
