# Make sure we don't wipe out eth0
network_interface 'eth0'

# Add additional interface configs
network_interface 'eth1'

# Add an interface config using platform specific provider
rhel_network_interface 'eth2' if %w(rhel fedora).include? node['platform_family']
debian_network_interface 'eth2' if %w(debian).include? node['platform_family']
