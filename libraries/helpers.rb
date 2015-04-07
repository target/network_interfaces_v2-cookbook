#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
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

    #
    # Check resource collection for any interfaces setup for bridge
    #
    def bridge_defined?
      return debian_bridge_defined? if node['platform_family'] == 'debian'
      return rhel_bridge_defined? if %w(rhel fedora).include? node['platform_family']
    end

    #
    # Check resource collection for any interfaces setup with metric
    #
    def metric_defined?
      return debian_metric_defined? if node['platform_family'] == 'debian'
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

    #
    # Check if any bridge interfaces defined for debain
    #
    def debian_bridge_defined?
      !debian_interfaces.reject { |r| r.bridge_ports.nil? }.empty?
    end

    #
    # Check if any bridge interfaces defined for rhel
    #
    def rhel_bridge_defined?
      !rhel_interfaces.reject { |r| r.bridge_device.nil? }.empty?
    end

    #
    # Check if any interfaces have metric defined for debain
    #
    def debian_metric_defined?
      !debian_interfaces.reject { |r| r.metric.nil? }.empty?
    end
  end
end

Chef::Recipe.send(:include, ::NetworkInterfacesV2::Helpers)
Chef::Resource.send(:include, ::NetworkInterfacesV2::Helpers)
