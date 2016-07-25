include_recipe 'fake::core'
include_recipe 'fake::bonding'
include_recipe 'fake::bridge'
include_recipe 'fake::vlan'
include_recipe 'fake::multiple_int_defs' if %w(debian ubuntu).include?(node['platform_family'])
