#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: debian_network_interface
#
# Copyright:: 2015, Target Corporation
#

require_relative 'resource_network_interface'

class Chef
  class Resource
    class  NetworkInterface
      #
      # Chef Resource for a debian_network_interface
      #
      class Debian < Chef::Resource::NetworkInterface

        provides :debian_network_interface
        provides :network_interface, os: 'linux', platform_family: %w(debian)

        def initialize(name, run_context = nil)
          super
          @resource_name = :debian_network_interface
          @provider = Chef::Provider::NetworkInterface::Debian

          @source = 'debian_interface.erb'
        end

        def bridge_ports(arg = nil)
          set_or_return(:bridge_ports, arg, :kind_of => Array)
        end

        def metric(arg = nil)
          set_or_return(:metric, arg, :kind_of => Integer)
        end

        def vlan_dev(arg = nil)
          set_or_return(:vlan_dev, arg, :kind_of => String)
        end

        def bond_slaves(arg = nil)
          set_or_return(:bond_slaves, arg, :kind_of => String)
        end

        def type(arg = nil)
          set_or_return(:type, @bootproto, :kind_of => String) if @type.nil?
          set_or_return(:type, arg, :kind_of => String)
        end

        def pre_up(arg = nil)
          set_or_return(:pre_up, arg, :kind_of => String)
        end

        def up(arg = nil)
          set_or_return(:up, arg, :kind_of => String)
        end

        def post_up(arg = nil)
          set_or_return(:post_up, arg, :kind_of => String)
        end

        def pre_down(arg = nil)
          set_or_return(:pre_down, arg, :kind_of => String)
        end

        def down(arg = nil)
          set_or_return(:down, arg, :kind_of => String)
        end

        def post_down(arg = nil)
          set_or_return(:post_down, arg, :kind_of => String)
        end

        def custom(arg = nil)
          set_or_return(:custom, arg, :kind_of => Hash)
        end
      end
    end
  end
end
