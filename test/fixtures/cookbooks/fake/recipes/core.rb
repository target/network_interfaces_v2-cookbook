if %w(rhel fedora).include? node['platform_family']
  if node['platform_version'].to_i <= 6
    include_recipe 'fake::_core_eth'
  else
    include_recipe 'fake::_core_enp'
  end
end

if %w(debian ubuntu).include? node['platform_family']
  if node['platform_version'] < '16.04'
    include_recipe 'fake::_core_eth'
  else
    include_recipe 'fake::_core_enp'
  end
end

include_recipe 'fake::_core_win' if node['os'] == 'windows'
