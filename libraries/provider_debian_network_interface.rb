#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: debian_network_interface
#
# Copyright:: 2015, Target Corporation
#

require 'chef/provider/lwrp_base'
require_relative 'provider_network_interface'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for Debian Network Interfaces
      #
      class Debian < Chef::Provider::NetworkInterface

        provides :debian_network_interface, os: 'linux', platform_family: %w(debian)

        def create_if_missing_interface
          log "debian_network_interface create_if_missing #{new_resource.device}"
        end

        def create_interface
          log "debian_network_interface create #{new_resource.device}"

          node.default['network_interfaces_v2']['metrics'] = true unless new_resource.metric.nil?
          node.default['network_interfaces_v2']['vlan'] = true if new_resource.vlan_dev || new_resource.device =~ /(eth|bond|wlan)[0-9]+\.[0-9]+/
          node.default['network_interfaces_v2']['bonding'] = true if new_resource.bond_slaves
          node.default['network_interfaces_v2']['bridge'] = true if new_resource.bridge_ports

          run_context.include_recipe 'network_interfaces_v2::_debian'

          template "/etc/network/interfaces.d/#{new_resource.device}" do
            cookbook new_resource.cookbook
            source new_resource.source
            mode 0644
            variables :device => new_resource.device,
                      :type => new_resource.type,
                      :auto => new_resource.onboot,
                      :address => new_resource.address,
                      :netmask => new_resource.mask,
                      :gateway => new_resource.gateway,
                      :broadcast => new_resource.broadcast,
                      :bridge_ports => new_resource.bridge_ports,
                      :bridge_stp => new_resource.bridge_stp,
                      :vlan_dev => new_resource.vlan_dev,
                      :bond_slaves => new_resource.bond_slaves,
                      :bond_mode => new_resource.bond_mode,
                      :mtu => new_resource.mtu,
                      :metric => new_resource.metric
            notifies :run, 'execute[merge interface configs]', :delayed
          end
        end
      end
    end
  end
end
