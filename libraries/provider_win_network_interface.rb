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

        #
        # Install/Load dependency libraries
        #
        def load_deps
          run_context.include_recipe 'network_interfaces_v2::_win'

          # Only load libraries on Windows
          require 'ruby-wmi' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
          require_relative 'ruby_wmi_ext' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        end

        #
        # Load current state of defined resource
        #
        def load_current_resource
          load_deps

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

        #
        # Create action to create/update the resource
        #
        def action_create
          load_deps

          # Rename
          phys_rename unless phys_adapter.net_connection_id == phys_adapter_name

          # Create new VLAN adapter if missing
          powershell_script "create vlan device #{new_resource.device}" do
            code "New-NetlbfoTeam -Name '#{new_resource.device}' -TeamMembers '#{new_resource.device}-NIC' -Confirm:$False"
            not_if { new_resource.vlan.nil? }
            not_if do
              `powershell Get-NetlbfoTeam -Name '#{new_resource.device}'`
              $?.success?
            end
            not_if do
              `powershell Get-NetlbfoTeamNic -Name '#{new_resource.device} - VLAN #{new_resource.vlan}'`
              $?.success?
            end
          end.run_action(:run)

          # Make sure proper VLAN is added to VLAN adapter
          powershell_script "set vlan on #{new_resource.device}" do
            code "Set-NetLbfoTeamNIC -Name '#{new_resource.device}' -VlanID #{new_resource.vlan}"
            not_if { new_resource.vlan.nil? }
            not_if do
              stdout = `powershell (Get-NetlbfoTeamNic -Name '#{new_resource.device}').VlanID -eq #{new_resource.vlan}`.chomp
              !$?.success? || stdout == 'True'
            end
            not_if do
              `powershell Get-NetlbfoTeamNic -Name '#{new_resource.device} - VLAN #{new_resource.vlan}'`
              $?.success?
            end
          end.run_action(:run)

          powershell_script "rename vlan adapter back to #{new_resource.device}" do
            code "Get-NetAdapter -Name '#{new_resource.device} - Vlan #{new_resource.vlan}' | Rename-NetAdapter -NewName '#{new_resource.device}'"
            not_if { new_resource.vlan.nil? }
            not_if do
              stdout = `powershell (Get-NetlbfoTeamNic -Name '#{new_resource.device}').VlanID -eq #{new_resource.vlan}`.chomp
              !$?.success? || stdout == 'True'
            end
            only_if do
              `powershell Get-NetlbfoTeamNic -Name '#{new_resource.device} - VLAN #{new_resource.vlan}'`
              $?.success?
            end
          end.run_action(:run)

          enable_dhcp if new_resource.bootproto == 'dhcp' && current_resource.bootproto != 'dhcp'
          if new_resource.bootproto == 'static'
            config_static unless new_resource.address.nil? || (current_resource.address == new_resource.address && current_resource.netmask == new_resource.netmask)
            config_gateway unless new_resource.gateway.nil? || current_resource.gateway == new_resource.gateway
          end
          config_dns unless new_resource.dns.nil? || current_resource.dns == new_resource.dns
          config_ddns unless new_resource.ddns.nil? || current_resource.ddns == new_resource.ddns
          config_dns_search unless new_resource.dns_search.nil? || current_resource.dns_search == new_resource.dns_search
        end

        private

        #
        # A WMI instance of the Network Adapter found by MAC
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

        #
        # converge_by wrapper
        #   Adds logging and updating the updated_by_last_action
        #
        def converge_it(msg, &block)
          converge_by(msg) do
            Chef::Log.info msg
            yield
            new_resource.updated_by_last_action true
          end
        end

        #
        # Enabled DHCP
        #
        def enable_dhcp
          converge_it('Enabling DHCP') do
            nic.EnableDhcp
          end
        end

        #
        # Configure static address
        #
        def config_static
          converge_it("Setting IP to #{new_resource.address}/#{new_resource.netmask}") do
            nic.EnableStatic([new_resource.address], [new_resource.netmask])
          end
        end

        #
        # Configure gateway
        #
        def config_gateway
          converge_it("Setting gateway to #{new_resource.gateway}") do
            nic.SetGateways([new_resource.gateway])
          end
        end

        #
        # Configure DNS
        #
        def config_dns
          converge_it("Setting DNS to: #{new_resource.dns.inspect}") do
            nic.SetDNSServerSearchOrder(new_resource.dns)
          end
        end

        #
        # Configure dynamic DNS registration
        #
        def config_ddns
          converge_it("#{new_resource.ddns ? 'Enabling' : 'Disabling'} dynamic DNS registration") do
            nic.SetDynamicDNSRegistration(new_resource.ddns)
          end
        end

        #
        # Configure DNS suffix search order
        #
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

        #
        # Rename the physical interface
        #
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
