directory '/etc/network/interfaces.d'

# Get the contents of the managed_directory on disk
directory_contents = Dir.glob('/etc/network/interfaces.d/*')

# Walk the resource collection to find managed device files
managed_files = run_context.resource_collection.all_resources.map do |r|
  "/etc/network/interfaces.d/#{r.device}" if [:debian_network_interface, :network_interface].include? r.declared_type
end.compact

# Remove any contents that appear to be unmanaged
# We use the File resource for this so that the activity is visibile
# to report handlers.
files_to_remove = directory_contents - managed_files
files_to_remove.each do |f|
  file f do
    action :delete
  end
end

# Add local interface unless it's defined or told not to
debian_network_interface 'manage lo' do
  device 'lo'
  type 'loopback'
  pre_up nil
  only_if { node['network_interfaces_v2']['debian']['manage_lo'] }

  # Do not manage if another network resource is defined already with device of 'lo'
  not_if do
    run_context.resource_collection.all_resources.find do |r|
      next unless [:debian_network_interface, :network_interface].include? r.declared_type
      next if r.name == 'manage lo'
      r.device == 'lo'
    end
  end
end

execute 'merge interface configs' do
  command 'cat /etc/network/interfaces.d/* > /etc/network/interfaces'
  action :nothing
end

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
