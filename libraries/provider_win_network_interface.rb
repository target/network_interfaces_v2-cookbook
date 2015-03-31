#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: win_network_interface
#
# Copyright:: 2015, Target Corporation
#

require 'chef/provider/lwrp_base'
require_relative 'provider_network_interface'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for Windows Network Interfaces
      #
      class Win < Chef::Provider::NetworkInterface

        provides :win_network_interface, os: 'windows'

        def load_deps
          run_context.include_recipe 'network_interfaces_v2::_win'

          if RUBY_PLATFORM =~ /mswin|mingw32|windows/
            require 'ruby-wmi'
            require_relative 'ruby_wmi_ext'
          end
        end

        def load_current_resource
          load_deps

          # Will load if windows and fail silently on other platform
          # begin
          #   require_relative 'ruby_wmi_ext'
          # rescue LoadError; end

          @current_resource = Chef::Resource::NetworkInterface::Win.new(@new_resource.name)
          @current_resource.name(@new_resource.name)
          @current_resource.hw_address(@new_resource.hw_address)

          @current_resource.device(adapter.net_connection_id)
          @current_resource.address(nic.ip_address.first) unless nic.ip_address.nil?
          @current_resource.netmask(nic.ip_subnet.first) unless nic.ip_subnet.nil?
          @current_resource.gateway(nic.default_ip_gateway.first) unless nic.default_ip_gateway.nil?
          @current_resource.dns(nic.dns_server_search_order)
          @current_resource.ddns(nic.full_dns_registration_enabled)
          @current_resource.dns_search(nic.dns_domain_suffix_search_order)

          case nic.dhcp_enabled
          when true
            @current_resource.bootproto('dhcp')
          else
            @current_resource.bootproto('static')
          end

          @current_resource
        end

        def action_create
          load_deps

          # Rename
          phys_rename unless current_resource.device == phys_adapter_name

          # If the NIC needs to be VLAN tagged we need to team it and then tag the teamed adapter that was created
          powershell_script "setup vlan #{new_resource.device}" do
            guard_interpreter :powershell_script
            code <<-EOH
              $newTeam = New-NetlbfoTeam -Name "#{new_resource.device}" -TeamMembers "#{new_resource.device}-NIC" -Confirm:$False
              Set-NetLbfoTeamNIC -Name $newTeam.Name -VlanID #{new_resource.vlan}
              Get-NetAdapter -Name "#{new_resource.device} - Vlan #{new_resource.vlan}" | Rename-NetAdapter -NewName "#{new_resource.device}"
            EOH
            # notifies :run, "powershell_script[ip_nic_#{new_resource.device}]", :immediately
            not_if { new_resource.vlan.nil? }
            not_if "(Get-NetlbfoTeam -Name '#{new_resource.device}')"
          end

          enable_dhcp if new_resource.bootproto == 'dhcp' && current_resource.bootproto != 'dhcp'
          if new_resource.bootproto == 'static'
            config_static unless new_resource.address.nil? || current_resource.address == new_resource.address || current_resource.netmask == new_resource.netmask
            config_gateway unless new_resource.gateway.nil? || current_resource.gateway == new_resource.gateway
          end
          config_dns unless new_resource.dns.nil? || current_resource.dns == new_resource.dns
          config_ddns unless new_resource.ddns.nil? || current_resource.ddns == new_resource.ddns
          config_dns_search unless new_resource.dns_search.nil? || current_resource.dns_search == new_resource.dns_search
        end

        private

        #
        # An WMI instance of the Network Adapter found by MAC
        #
        # @return [RubyWMI::Win32_NetworkAdapter]
        #
        def phys_adapter
          @phys_adapter ||= begin
            a = ::WMI::Win32_NetworkAdapter.find(:all, conditions: conditions)
            fail Chef::Exceptions::UnsupportedAction, "Failed to find interface with conditions: #{conditions}" if a.empty?
            a.first
          end
        end

        #
        # The data structure to search for the interface we want to manage
        #
        # @return [Hash]
        #
        def conditions
          c = {}
          c[:index] = new_resource.index unless new_resource.index.nil?
          c[:mac_address] = new_resource.hw_address unless new_resource.hw_address.nil?
          fail Chef::Exceptions::UnsupportedAction, 'Failed to find interface, no conditions provided' if c.empty?
          c
        end

        #
        # An WMI instance of the Network Adapter found by name
        #
        # @return [RubyWMI::Win32_NetworkAdapter]
        #
        def adapter
          a = ::WMI::Win32_NetworkAdapter.find(:all, conditions: { net_connection_id: new_resource.device })
          a = ::WMI::Win32_NetworkAdapter.find(:all, conditions: conditions) if a.empty?
          a.first
        end

        #
        # NIC configuration for adapter
        #
        # @return [RubyWMI::Win32_NetworkAdapterConfiguration]
        #
        def nic
          ::WMI::Win32_NetworkAdapterConfiguration.find(:all, conditions: { interface_index: adapter.InterfaceIndex }).first
        end

        def converge_it(msg, &block)
          converge_by(msg) do
            Chef::Log.info msg
            yield
            new_resource.updated_by_last_action true
          end
        end

        def enable_dhcp
          converge_it('Enabling DHCP') do
            nic.EnableDhcp
          end
        end

        def config_static
          converge_it("Setting IP to #{new_resource.address}/#{new_resource.netmask}") do
            nic.EnableStatic([new_resource.address], [new_resource.netmask])
          end
        end

        def config_gateway
          converge_it("Setting gateway to #{new_resource.gateway}") do
            nic.SetGateways(new_resource.gateway)
          end
        end

        def config_dns
          converge_it("Setting DNS to: #{new_resource.dns.inspect}") do
            nic.SetDNSServerSearchOrder(new_resource.dns)
          end
        end

        def config_ddns
          converge_it("#{new_resource.ddns ? 'Enabling' : 'Disabling'} dynamic DNS registration") do
            nic.SetDynamicDNSRegistration(new_resource.ddns)
          end
        end

        def config_dns_search
          converge_it("Setting DNS search: #{new_resource.dns_search.inspect}") do
            nic.SetDNSSuffixSearchOrder(new_resource.dns_search)
          end
        end

        #
        # Name to set to physical adapter
        #   Append '-NIC' to physical if tagging on VLANs
        #
        def phys_adapter_name
          new_resource.vlan.nil? ? new_resource.device : "#{new_resource.device}-NIC"
        end

        def phys_rename
          converge_it("Renaming #{phys_adapter.NetConnectionID} to #{phys_adapter_name}") do
            phys_adapter.NetConnectionID = phys_adapter_name
            phys_adapter.Put_
          end
        end
      end
    end
  end
end
