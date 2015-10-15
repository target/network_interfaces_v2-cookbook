#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: win_network_interface
#
# Copyright:: 2015, Target Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/lwrp_base'
require_relative 'provider_network_interface'
require_relative 'wmi_helper'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for Windows Network Interfaces
      #
      class Win < Chef::Provider::NetworkInterface # rubocop:disable ClassLength
        provides :win_network_interface, os: 'windows' if respond_to?(:provides)

        #
        # Load current state of defined resource
        #
        def load_current_resource # rubocop:disable MethodLength, AbcSize
          @current_resource = Chef::Resource::NetworkInterface::Win.new(@new_resource.name)
          @current_resource.name(@new_resource.name)
          @current_resource.hw_address(@new_resource.hw_address)

          @current_resource.device(adapter.NetConnectionID)
          @current_resource.gateway(nic.DefaultIPGateway.first) unless nic.DefaultIPGateway.nil?
          @current_resource.dns(nic.DNSServerSearchOrder)
          @current_resource.dns_domain(nic.DNSDomain)
          @current_resource.ddns(nic.FullDNSRegistrationEnabled)

          @current_resource.addresses = nic.IPAddress
          @current_resource.netmasks = nic.IPSubnet

          case nic.TCPIPNetbiosOptions
          when 0
            @current_resource.netbios 'dhcp'
          when 1
            @current_resource.netbios true
          when 2
            @current_resource.netbios false
          end

          case nic.DHCPEnabled
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
        action :create do
          manage_phys_name
          manage_vlan
          manage_address
          manage_dns
          manage_netbios
          post_updates
        end

        private

        #
        # Rename physical interface if needed
        #
        def manage_phys_name
          phys_rename unless phys_adapter.NetConnectionID == phys_adapter_name
        end

        #
        # Manage VLAN as needed
        #
        def manage_vlan # rubocop:disable CyclomaticComplexity
          return if new_resource.vlan.nil?
          create_vlan_dev unless vlan_dev_exist? || msft_vlan_dev_exist?
          set_vlan unless vlanid_set? || msft_vlan_dev_exist?
          rename_vlan_dev if msft_vlan_dev_exist?
          load_current_resource # Reload current resource with values from new vlan int
        end

        #
        # Manage IP addresses as needed
        #
        def manage_address # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity
          enable_dhcp if new_resource.bootproto == 'dhcp' && current_resource.bootproto != 'dhcp'
          return unless new_resource.bootproto == 'static'

          config_static unless new_resource.address.nil? || (current_resource.bootproto == 'static' && ip_subnet_exist?)
          config_gateway unless new_resource.gateway.nil? || (current_resource.bootproto == 'static' && current_resource.gateway == new_resource.gateway)
        end

        #
        # Manage DNS as needed
        #
        def manage_dns # rubocop:disable AbcSize, CyclomaticComplexity
          config_dns unless new_resource.dns.nil? || current_resource.dns == new_resource.dns
          config_dns_domain unless new_resource.dns_domain.nil? || current_resource.dns_domain == new_resource.dns_domain
          config_ddns unless new_resource.ddns.nil? || current_resource.ddns == new_resource.ddns
        end

        #
        # Manage NetBIOS as needed
        #
        def manage_netbios
          config_netbios unless current_resource.netbios == new_resource.netbios
        end

        #
        # Manage additional updates after interface has been reconfigured
        #
        def post_updates
          reload if new_resource.updated_by_last_action? && new_resource.reload
          post_up(new_resource.post_up) unless new_resource.post_up.nil? || !new_resource.updated_by_last_action?
        end

        #
        # A WMI instance of the Network Adapter found by MAC
        #
        # @return [RubyWMI::Win32_NetworkAdapter]
        #
        def phys_adapter
          @phys_adapter ||= begin
            a = execute_wmi_query("select * from Win32_NetworkAdapter where #{conditions}")
            fail Chef::Exceptions::UnsupportedAction, "Failed to find interface with conditions: #{conditions}" if a.nil?
            wmi_object_array(a).first
          end
        end

        #
        # The data structure to search for the interface we want to manage
        #
        # @return [Hash]
        #
        def conditions # rubocop:disable AbcSize
          c = []
          c << "Index='#{new_resource.index}'" unless new_resource.index.nil?
          c << "MacAddress='#{new_resource.hw_address}'" unless new_resource.hw_address.nil?
          fail Chef::Exceptions::UnsupportedAction, 'Failed to find interface, no conditions provided' if c.empty?
          c.join(' AND ')
        end

        #
        # An WMI instance of the Network Adapter found by name
        #
        # @return [RubyWMI::Win32_NetworkAdapter]
        #
        def adapter
          a = execute_wmi_query("select * from Win32_NetworkAdapter where NetConnectionID='#{new_resource.device}'")
          a = execute_wmi_query("select * from Win32_NetworkAdapter where #{conditions}") if a.nil?
          wmi_object_array(a).first
        end

        #
        # NIC configuration for adapter
        #
        # @return [RubyWMI::Win32_NetworkAdapterConfiguration]
        #
        def nic
          a = execute_wmi_query("select * from Win32_NetworkAdapterConfiguration where InterfaceIndex='#{adapter.InterfaceIndex}'")
          wmi_object_array(a).first
        end

        #
        # converge_by wrapper
        #   Adds logging and updating the updated_by_last_action
        #
        def converge_it(msg, &_block)
          converge_by(msg) do
            Chef::Log.info msg
            yield
            new_resource.updated_by_last_action true
          end
        end

        #
        # Check if initial VLAN device exists
        #
        def vlan_dev_exist?
          shell_out = Mixlib::ShellOut.new("powershell.exe -Command \"Get-NetlbfoTeam -Name '#{new_resource.device}'\"")
          shell_out.run_command
          !shell_out.error?
        end

        #
        # Check if VLAN device exists with MSFT naming
        #
        def msft_vlan_dev_exist?
          shell_out = Mixlib::ShellOut.new("powershell.exe -Command \"Get-NetlbfoTeamNic -Name '#{new_resource.device} - VLAN #{new_resource.vlan}'\"")
          shell_out.run_command
          !shell_out.error?
        end

        #
        # Check if VLANID is set on VLAN device
        #
        def vlanid_set?
          shell_out = Mixlib::ShellOut.new("powershell.exe -Command \"(Get-NetlbfoTeamNic -Name '#{new_resource.device}').VlanID -eq #{new_resource.vlan}\"")
          shell_out.run_command

          return false if shell_out.error?
          shell_out.stdout.chomp == 'True'
        end

        #
        # Check if IP/subnet is already configured
        #
        def ip_subnet_exist?
          ip_exist? && subnet_exist?
        end

        #
        # Chef if IP address is already configured
        #
        def ip_exist?
          return false if current_resource.addresses.nil?
          current_resource.addresses.include?(new_resource.address)
        end

        #
        # Chef if subnet address is already configured
        #
        def subnet_exist? # rubocop:disable AbcSize
          return false if current_resource.netmasks.nil? || current_resource.addresses.nil?
          current_resource.netmasks[current_resource.addresses.index(new_resource.address)] == new_resource.netmask
        end

        #
        # Create new VLAN device
        #
        def create_vlan_dev
          converge_it("Create VLAN adapter #{new_resource.device}") do
            shell_out = Mixlib::ShellOut.new("powershell.exe -Command \"New-NetlbfoTeam -Name '#{new_resource.device}' -TeamMembers '#{new_resource.device}-NIC' -Confirm:$False\"")
            shell_out.run_command
            shell_out.error!
          end
        end

        #
        # Set VLAN ID on VLAN device
        #
        def set_vlan
          converge_it("Set VLAN #{new_resource.vlan} on adapter #{new_resource.device}") do
            shell_out = Mixlib::ShellOut.new("powershell.exe -Command \"Set-NetLbfoTeamNIC -Name '#{new_resource.device}' -VlanID #{new_resource.vlan}\"")
            shell_out.run_command
            shell_out.error!
          end
        end

        #
        # Rename VLAN device to name we want from MSFT naming convention
        #
        def rename_vlan_dev # rubocop:disable AbcSize
          converge_it("Renaming VLAN dev '#{new_resource.device} - Vlan #{new_resource.vlan}' back to '#{new_resource.device}'") do
            shell_out = Mixlib::ShellOut
                        .new("powershell.exe -Command \"Get-NetAdapter -Name '#{new_resource.device} - Vlan #{new_resource.vlan}' | Rename-NetAdapter -NewName '#{new_resource.device}'\"")
            shell_out.run_command
            shell_out.error!
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
        # Configure NetBIOS
        #
        def config_netbios # rubocop:disable MethodLength
          case new_resource.netbios
          when true
            converge_it('Enabling NetBIOS') do
              nic.SetTcpipNetbios(1)
            end
          when false
            converge_it('Disabling NetBIOS') do
              nic.SetTcpipNetbios(2)
            end
          when 'dhcp'
            converge_it('Enabling NetBIOS via DHCP') do
              nic.SetTcpipNetbios(0)
            end
          end
        end

        #
        # Release DHCP addresses
        #
        def release_dhcp_addresses
          converge_it("Released DHCP addresses on #{new_resource.device}") do
            nic.ReleaseDHCPLease
          end
        end

        #
        # IPs to set on interface
        #  Takes existing IPs and adds the wanted IP to the front
        #  Also removes IPv6 addresses
        #
        def wanted_ips
          ips = [new_resource.address, nic.IPAddress].flatten.compact

          # Return only IPv4 IPs
          ips.select { |ip| ip =~ /\./ }
        end

        #
        # Netmasks to set on interface
        #  Takes existing netmasks and adds the wanted netmask to the front
        #  Also removes IPv6 addresses
        #
        def wanted_netmasks
          netmasks = [new_resource.netmask, nic.IPSubnet].flatten.compact

          # Return only IPv4 netmasks
          netmasks.select { |ip| ip =~ /\./ }
        end

        #
        # Configure static address
        #
        def config_static
          release_dhcp_addresses if current_resource.bootproto == 'dhcp'

          converge_it("Set IP to #{new_resource.address}/#{new_resource.netmask}") do
            nic.EnableStatic(wanted_ips, wanted_netmasks)
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
        # Configure DNS Domain
        #
        def config_dns_domain
          converge_it("Setting DNS Domain to: #{new_resource.dns_domain}") do
            nic.SetDNSDomain(new_resource.dns_domain)
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

        #
        # Disable and Enable the interface
        #
        def reload
          converge_it("Reloading #{new_resource.device}") do
            adapter.disable
            sleep 5
            adapter.enable
          end
        end

        def post_up(cmd)
          shell_out = Mixlib::ShellOut.new("powershell.exe -Command '#{cmd}'")
          shell_out.run_command
          shell_out.error!
        end
      end
    end
  end
end
