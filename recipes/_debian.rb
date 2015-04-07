#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Recipe:: _debian
#
# Copyright:: 2015, Target Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'modules::default'

directory '/etc/network/interfaces.d'

# Get the contents of the managed_directory on disk
directory_contents = Dir.glob('/etc/network/interfaces.d/*')

# Walk the resource collection to find managed device files
managed_files = run_context.resource_collection.all_resources.map do |r|
  f = "/etc/network/interfaces.d/#{r.device}" if [:debian_network_interface, :network_interface].include? r.declared_type if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')
  f = "/etc/network/interfaces.d/#{r.device}" if [:debian_network_interface, :network_interface].include? r.resource_name unless Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')
  f
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

cookbook_file '/etc/network/interfaces'

package 'vlan' do
  only_if { vlan_defined? }
end
modules '8021q' do
  only_if { vlan_defined? }
end

package 'ifenslave-2.6' do
  only_if { bond_defined? }
end
modules 'bonding' do
  only_if { bond_defined? }
end

package 'ifmetric' do
  only_if { metric_defined? }
end

package 'bridge-utils' do
  only_if { bridge_defined? }
end
