if %w(rhel fedora).include? node['platform_family']
  if node['platform_version'].to_i <= 6
    include_recipe 'fake::_core_rhel6'
  else
    include_recipe 'fake::_core_rhel'
  end
end
include_recipe 'fake::_core_debian' if node['platform_family'] == 'debian'
include_recipe 'fake::_core_win' if node['os'] == 'windows'
