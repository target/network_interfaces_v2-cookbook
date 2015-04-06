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

    #
    # Check resource collection for any interfaces setup for vlan
    #
    def vlan_defined?
      return debian_vlan_defined? if node['platform_family'] == 'debian'
      return rhel_vlan_defined? if %w(rhel fedora).include? node['platform_family']
      return win_vlan_defined? if node['os'] == 'windows'
    end

    private

    #
    # All defined debian_network_interface in Chef resource collection
    #
    def debian_interfaces
      run_context.resource_collection.all_resources.find_all { |r| r.resource_name == :debian_network_interface }
    end

    #
    # All defined rhel_network_interface in Chef resource collection
    #
    def rhel_interfaces
      run_context.resource_collection.all_resources.find_all { |r| r.resource_name == :rhel_network_interface }
    end

    #
    # All defined win_network_interface in Chef resource collection
    #
    def win_interfaces
      run_context.resource_collection.all_resources.find_all { |r| r.resource_name == :win_network_interface }
    end

    #
    # Check if any bond interfaces defined for debain
    #
    def debian_bond_defined?
      !debian_interfaces.reject { |r| r.bond_slaves.nil? }.empty?
    end

    #
    # Check if any bond interfaces defined for rhel
    #
    def rhel_bond_defined?
      !rhel_interfaces.reject { |r| r.bond_master.nil? }.empty?
    end

    #
    # Check if any vlan interfaces defined for debain
    #
    def debian_vlan_defined?
      !debian_interfaces.reject { |r| r.vlan.nil? }.empty?
    end

    #
    # Check if any vlan interfaces defined for rhel
    #
    def rhel_vlan_defined?
      !rhel_interfaces.reject { |r| r.vlan.nil? }.empty?
    end

    #
    # Check if any vlan interfaces defined for win
    #
    def win_vlan_defined?
      !win_interfaces.reject { |r| r.vlan.nil? }.empty?
    end
  end
end

Chef::Recipe.send(:include, ::NetworkInterfacesV2::Helpers)
Chef::Resource.send(:include, ::NetworkInterfacesV2::Helpers)
