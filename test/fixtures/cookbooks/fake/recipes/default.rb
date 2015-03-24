# Make sure we don't wipe out eth0
network_interface 'eth0'

# Add a dummy interface configs
network_interface 'eth10'

# Add a dummy interface config using platform specific provider
rhel_network_interface 'eth11' if %w(rhel fedora).include? node['platform_family']
debian_network_interface 'eth11' if %w(debian).include? node['platform_family']
