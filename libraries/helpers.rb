module NetworkInterfacesV2
  #
  # Helper methods for network_interfaces_v2 cookbook
  #
  module Helpers
    #
    # Check resource collection for any interfaces setup for bonding
    #
    def bond_defined?
      return debian_bond_defined? if node['platform_family'] == 'debian'
      return rhel_bond_defined? if %w(rhel fedora).include? node['platform_family']
    end

    private

    def debian_bond_defined?
      !run_context.resource_collection.all_resources.find_all { |r| r.resource_name == :debian_network_interface && !r.bond_slaves.nil? }.empty?
    end

    def rhel_bond_defined?
      !run_context.resource_collection.all_resources.find_all { |r| r.resource_name == :rhel_network_interface && !r.bond_master.nil? }.empty?
    end
  end
end

Chef::Recipe.send(:include, ::NetworkInterfacesV2::Helpers)
Chef::Resource.send(:include, ::NetworkInterfacesV2::Helpers)
