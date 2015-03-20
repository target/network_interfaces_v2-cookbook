#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: rhel_network_interface
#
# Copyright:: 2015, Target Corporation
#

require_relative 'provider_network_interface'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for RHEL Network Interfaces
      #
      class Rhel < Chef::Provider::NetworkInterface

        provides :rhel_network_interface, os: 'linux', platform_family: %w(rhel fedora)

        def create_if_missing_interface
          Chef::Log.info "rhel_network_interface create_if_missing #{new_resource.device}"

          device_config_file = Chef::Resource::Template.new("/var/tmp/ifcfg-#{new_resource.device}", run_context)
          device_config_file.source 'ifcfg.erb'
          device_config_file.cookbook 'network_interfaces_v2'
          device_config_file.run_action(:create)
        end

        def create_interface
          Chef::Log.info "rhel_network_interface create #{new_resource.device}"

          device_config_file = Chef::Resource::Template.new("/var/tmp/ifcfg-#{new_resource.device}", run_context)
          device_config_file.source 'ifcfg.erb'
          device_config_file.cookbook 'network_interfaces_v2'
          device_config_file.run_action(:create)
        end
      end
    end
  end
end
