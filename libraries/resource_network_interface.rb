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

        @nm_controlled = true
        @onboot = true
      end

      def device(arg = nil)
        set_or_return(:device, arg, :kind_of => String)
      end

      # def bridge(arg = nil)
      #   set_or_return(:bridge, arg, :kind_of => [TrueClass, FalseClass, Array])
      # end
      #
      # def bridgedevice(arg = nil)
      #   set_or_return(:bridgedevice, arg, :kind_of => String)
      # end
      #
      # def bridge_stp(arg = nil)
      #   set_or_return(:bridge_stp, arg, :kind_of => [TrueClass, FalseClass])
      # end

      def bond(arg = nil)
        set_or_return(:bond, arg, :kind_of => [TrueClass, FalseClass, Array])
      end

      def bond_mode(arg = nil)
        set_or_return(:bond_mode, arg, :kind_of => String)
      end

      def bond_master(arg = nil)
        set_or_return(:bond_master, arg, :kind_of => String)
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

      def vlan(arg = nil)
        set_or_return(:vlan, arg, :kind_of => [TrueClass, FalseClass])
      end

      def vlan_dev(arg = nil)
        set_or_return(:vlan_dev, arg, :kind_of => String)
      end

      def onboot(arg = nil)
        set_or_return(:onboot, arg, :kind_of => [TrueClass, FalseClass])
      end

      def bootproto(arg = nil)
        set_or_return(:bootproto, arg, :kind_of => String)
      end

      def target(arg = nil)
        set_or_return(:target, arg, :kind_of => String)
      end

      def gateway(arg = nil)
        set_or_return(:gateway, arg, :kind_of => String)
      end

      def metric(arg = nil)
        set_or_return(:metric, arg, :kind_of => Integer)
      end

      def mtu(arg = nil)
        set_or_return(:mtu, arg, :kind_of => Integer)
      end

      def mask(arg = nil)
        set_or_return(:mask, arg, :kind_of => String)
      end

      def network(arg = nil)
        set_or_return(:network, arg, :kind_of => String)
      end

      def broadcast(arg = nil)
        set_or_return(:broadcast, arg, :kind_of => String)
      end

      # def pre_up(arg = nil)
      #   set_or_return(:pre_up, arg, :kind_of => String)
      # end
      #
      # def up(arg = nil)
      #   set_or_return(:up, arg, :kind_of => String)
      # end
      #
      # def post_up(arg = nil)
      #   set_or_return(:post_up, arg, :kind_of => String)
      # end
      #
      # def pre_down(arg = nil)
      #   set_or_return(:pre_down, arg, :kind_of => String)
      # end
      #
      # def down(arg = nil)
      #   set_or_return(:down, arg, :kind_of => String)
      # end
      #
      # def post_down(arg = nil)
      #   set_or_return(:post_down, arg, :kind_of => String)
      # end
      #
      # def custom(arg = nil)
      #   set_or_return(:custom, arg, :kind_of => Hash)
      # end

      # These are different or same?
      def mac_address(arg = nil)
        set_or_return(:mac_address, arg, :kind_of => String)
      end

      def hw_address(arg = nil)
        set_or_return(:hw_address, arg, :kind_of => String)
      end
    end
  end
end
