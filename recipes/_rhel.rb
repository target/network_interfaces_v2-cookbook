package 'vconfig' do
  only_if { vlan_defined? }
  only_if { node['platform_version'].to_i < 7 }
end

package 'iputils' do
  only_if { bond_defined? }
end

package 'bridge-utils' do
  only_if { node['network_interfaces_v2']['bridge'] }
end
