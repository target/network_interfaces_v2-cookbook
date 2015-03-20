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
        end
      end
    end
  end
end
