#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: win_network_interface
#
# Copyright:: 2015, Target Corporation
#

require_relative 'resource_network_interface'

class Chef
  class Resource
    class  NetworkInterface
      #
      # Chef Resource for a win_network_interface
      #
      class Win < Chef::Resource::NetworkInterface

        provides :win_network_interface
        provides :network_interface, os: 'windows'

        def initialize(name, run_context = nil)
          super
          @resource_name = :win_network_interface
          @provider = Chef::Provider::NetworkInterface::Win
        end

        def hw_address(arg = nil)
          arg = arg.gsub('-', ':').upcase unless arg.nil?
          set_or_return(:hw_address, arg, :kind_of => String, :regex => /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
        end

        def index(arg = nil)
          set_or_return(:index, arg, :kind_of => Integer)
        end

        def vlan(arg = nil)
          set_or_return(:vlan, arg, :kind_of => Integer)
        end

        def dns(arg = nil)
          set_or_return(:dns, arg, :kind_of => Array)
        end

        def ddns(arg = nil)
          set_or_return(:ddns, arg, :kind_of => [TrueClass, FalseClass])
        end

        def dns_search(arg = nil)
          set_or_return(:domain, arg, :kind_of => Array)
        end
      end
    end
  end
end
