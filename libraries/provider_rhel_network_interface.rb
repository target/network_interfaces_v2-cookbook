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

        def create_interface
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
                      :netmask => new_resource.netmask,
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
            notifies :run, "execute[reload interface #{new_resource.device}]", new_resource.reload_type if new_resource.reload
          end

          execute "reload interface #{new_resource.device}" do
            command <<-EOF
              ifdown #{new_resource.device}
              ifup #{new_resource.device}
            EOF
            action :nothing
          end
        end
      end
    end
  end
end
