include_recipe 'fake::_default_rhel' if %w(rhel fedora).include? node['platform_family']
include_recipe 'fake::_default_debian' if node['platform_family'] == 'debian'
include_recipe 'fake::_default_win' if node['os'] == 'windows'
