if %(rhel fedora).include? node['platform_family']
  if node['platform_version'].to_i <= 6
    include_recipe 'fake::_ovs_dhcp_eth'
  else
    include_recipe 'fake::_ovs_dhcp_enp'
  end
end
