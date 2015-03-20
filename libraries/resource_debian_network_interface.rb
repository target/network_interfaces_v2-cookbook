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
        provides :network_interface, os: 'linux', platform_family: %w(debian ubuntu)

        def initialize(name, run_context = nil)
          super
          @resource_name = :debian_network_interface
          @provider = Chef::Provider::NetworkInterface::Debian
        end
      end
    end
  end
end
