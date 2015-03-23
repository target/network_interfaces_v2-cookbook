directory '/etc/network/interfaces.d'

package 'vlan' do
  only_if { node['network_interfaces_v2']['vlan'] }
end
modules '8021q' do
  only_if { node['network_interfaces_v2']['vlan'] }
end

package 'ifenslave-2.6' do
  only_if { node['network_interfaces_v2']['bonding'] }
end
modules 'bonding' do
  only_if { node['network_interfaces_v2']['bonding'] }
end

package 'ifmetric' do
  only_if { node['network_interfaces_v2']['metrics'] }
end

package 'bridge-utils' do
  only_if { node['network_interfaces_v2']['bridge'] }
end
