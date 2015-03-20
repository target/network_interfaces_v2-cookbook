network_interface 'eth0'

rhel_network_interface 'eth1' if %w(rhel fedora).include? node['platform_family']

debian_network_interface 'eth2' if %w(debian ubuntu).include? node['platform_family']
