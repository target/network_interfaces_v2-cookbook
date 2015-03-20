#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: debian_network_interface
#
# Copyright:: 2015, Target Corporation
#

require_relative 'provider_network_interface'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for Debian Network Interfaces
      #
      class Debian < Chef::Provider::NetworkInterface

        provides :debian_network_interface, os: 'linux', platform_family: %w(debian ubuntu)

        def create_if_missing_interface
          Chef::Log.info "debian_network_interface create_if_missing #{new_resource.device}"
        end

        def create_interface
          Chef::Log.info "debian_network_interface create #{new_resource.device}"
        end
      end
    end
  end
end
