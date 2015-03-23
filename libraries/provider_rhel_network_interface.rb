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
          log "rhel_network_interface create_if_missing #{new_resource.device}"

          device_config_file = Chef::Resource::Template.new("/var/tmp/ifcfg-#{new_resource.device}", run_context)
          device_config_file.source new_resource.source
          device_config_file.cookbook new_resource.cookbook
          device_config_file.run_action :create
        end

        def create_interface
          log "rhel_network_interface create #{new_resource.device}"

          # if new_resource.bootproto == "dhcp"
          #   type = "dhcp"
          # elsif ! new_resource.target
          #   type = "none"
          # else
          #   type = "static"
          # end

          # execute "if_up" do
          #   command "ifdown #{new_resource.device} ; ifup #{new_resource.device}"
          #   action :nothing
          # end

          node.default['network_interfaces_v2']['vlan'] = true if new_resource.vlan || new_resource.device =~ /(eth|bond|wlan)[0-9]+\.[0-9]+/
          node.default['network_interfaces_v2']['bonding'] = true if new_resource.bond_master
          node.default['network_interfaces_v2']['bridge'] = true if new_resource.bridge_device

          run_context.include_recipe 'network_interfaces_v2::_rhel'

          template "/etc/sysconfig/network-scripts/ifcfg-#{new_resource.device}" do
            cookbook new_resource.cookbook
            source new_resource.source
            mode 0644
            variables :device => new_resource.device,
                      :type => new_resource.type,
                      :onboot => new_resource.onboot,
                      :bootproto => new_resource.bootproto,
                      :address => new_resource.address,
                      :network => new_resource.network,
                      :netmask => new_resource.mask,
                      :gateway => new_resource.gateway,
                      :mac_address => new_resource.mac_address,
                      :hw_address => new_resource.hw_address,
                      :broadcast => new_resource.broadcast,
                      :bridge_device => new_resource.bridge_device,
                      :bridge_stp => new_resource.bridge_stp,
                      :vlan => new_resource.vlan,
                      :bond_mode => new_resource.bond_mode,
                      :bond_master => new_resource.bond_master,
                      :nm_controlled => new_resource.nm_controlled,
                      :ipv6init => new_resource.ipv6init,
                      :nozeroconf => new_resource.nozeroconf,
                      :userctl => new_resource.userctl,
                      :peerdns => new_resource.peerdns,
                      :mtu => new_resource.mtu
          end
        end
      end
    end
  end
end
