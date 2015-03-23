#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: network_interface
#
# Copyright:: 2015, Target Corporation
#

require 'chef/resource'

class Chef
  class Resource
    #
    # Chef Resource for a network_interface
    #
    class  NetworkInterface < Chef::Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :network_interface
        @provider = Chef::Provider::NetworkInterface
        @action = :create
        @allowed_actions = [:create_if_missing, :create]

        # This is equivalent to setting :name_attribute => true
        @device = name

        @bootproto = 'dhcp'
        @onboot = true
        @cookbook = 'network_interfaces_v2'
        @source = 'ifcfg.erb'
      end

      def cookbook(arg = nil)
        set_or_return(:cookbook, arg, :kind_of => String)
      end

      def source(arg = nil)
        set_or_return(:source, arg, :kind_of => String)
      end

      def device(arg = nil)
        set_or_return(:device, arg, :kind_of => String)
      end

      def type(arg = nil)
        set_or_return(:type, arg, :kind_of => String)
      end

      # def bridge(arg = nil)
      #   set_or_return(:bridge, arg, :kind_of => [TrueClass, FalseClass, Array])
      # end

      def bridge_stp(arg = nil)
        set_or_return(:bridge_stp, arg, :kind_of => [TrueClass, FalseClass])
      end

      # def bond(arg = nil)
      #   set_or_return(:bond, arg, :kind_of => [TrueClass, FalseClass, Array])
      # end

      def bond_mode(arg = nil)
        set_or_return(:bond_mode, arg, :kind_of => String)
      end

      def onboot(arg = nil)
        set_or_return(:onboot, arg, :kind_of => [TrueClass, FalseClass])
      end

      def bootproto(arg = nil)
        set_or_return(:bootproto, arg, :kind_of => String)
      end

      def address(arg = nil)
        set_or_return(:address, arg, :kind_of => String)
      end

      def gateway(arg = nil)
        set_or_return(:gateway, arg, :kind_of => String)
      end

      def mtu(arg = nil)
        set_or_return(:mtu, arg, :kind_of => Integer)
      end

      def mask(arg = nil)
        set_or_return(:mask, arg, :kind_of => String)
      end

      def broadcast(arg = nil)
        set_or_return(:broadcast, arg, :kind_of => String)
      end
    end
  end
end
