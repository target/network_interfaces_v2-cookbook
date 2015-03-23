package 'vconfig' do
  only_if { node['network_interfaces_v2']['vlan'] }
  only_if { node['platform_version'].to_i < 7 }
end

package 'iputils' do
  only_if { node['network_interfaces_v2']['bonding'] }
end

package 'bridge-utils' do
  only_if { node['network_interfaces_v2']['bridge'] }
end
