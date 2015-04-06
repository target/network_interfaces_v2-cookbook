#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: rhel_network_interface
#
# Copyright:: 2015, Target Corporation
#

require_relative 'resource_network_interface'

class Chef
  class Resource
    class  NetworkInterface
      #
      # Chef Resource for a rhel_network_interface
      #
      class Rhel < Chef::Resource::NetworkInterface

        provides :rhel_network_interface
        provides :network_interface, os: 'linux', platform_family: %w(rhel fedora)

        def initialize(name, run_context = nil)
          super
          @resource_name = :rhel_network_interface
          @provider = Chef::Provider::NetworkInterface::Rhel

          @type = 'Ethernet'
          @nm_controlled = false
        end

        def nm_controlled(arg = nil)
          set_or_return(:nm_controlled, arg, :kind_of => [TrueClass, FalseClass])
        end

        def ipv6init(arg = nil)
          set_or_return(:ipv6init, arg, :kind_of => [TrueClass, FalseClass])
        end

        def nozeroconf(arg = nil)
          set_or_return(:nozeroconf, arg, :kind_of => [TrueClass, FalseClass])
        end

        def userctl(arg = nil)
          set_or_return(:userctl, arg, :kind_of => [TrueClass, FalseClass])
        end

        def peerdns(arg = nil)
          set_or_return(:peerdns, arg, :kind_of => [TrueClass, FalseClass])
        end

        def bridge_device(arg = nil)
          set_or_return(:bridge_device, arg, :kind_of => String)
        end

        def network(arg = nil)
          set_or_return(:network, arg, :kind_of => String)
        end

        def type(arg = nil)
          set_or_return(:type, arg, :kind_of => String)
        end

        def vlan(arg = nil)
          set_or_return(:vlan, arg, :kind_of => [TrueClass, FalseClass])
        end

        def mac_address(arg = nil)
          set_or_return(:mac_address, arg, :kind_of => String, :regex => /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
        end
      end
    end
  end
end
