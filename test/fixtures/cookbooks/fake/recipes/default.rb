network_interface 'eth10'

rhel_network_interface 'eth11' if %w(rhel fedora).include? node['platform_family']

debian_network_interface 'eth11' if %w(debian ubuntu).include? node['platform_family']
