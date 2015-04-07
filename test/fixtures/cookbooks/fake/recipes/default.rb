# Make sure we don't wipe out eth0
network_interface 'eth0' unless node['os'] == 'windows'

# Add additional interface configs
network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.11' if %w(rhel fedora).include? node['platform_family']
  address '10.12.10.12' if node['platform_family'] == 'debian'
  address '10.12.10.13' if node['os'] == 'windows'
  netmask '255.255.255.0'
  gateway node['network']['default_gateway'] unless node['os'] == 'windows'
  hw_address '00-25-B5-5B-00-25' if node['os'] == 'windows'
  gateway '10.12.10.1' if node['os'] == 'windows'
end

# Add an interface config using platform specific provider
rhel_network_interface 'eth2' if %w(rhel fedora).include? node['platform_family']
debian_network_interface 'eth2' if %w(debian).include? node['platform_family']

if node['os'] == 'windows'
  win_network_interface 'eth2' do
    hw_address '00-25-B5-5B-00-27'
    dns ['14.13.13.13', '14.13.13.12']
    ddns false
    dns_domain 'test.it.com'
  end
end
