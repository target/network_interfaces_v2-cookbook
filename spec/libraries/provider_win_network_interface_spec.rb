require 'spec_helper'

require 'chef/platform'
require 'chef/run_context'
require 'chef/resource'
require 'chef/event_dispatch/base'
require 'chef/event_dispatch/dispatcher'

require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/resource_network_interface.rb"
require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/provider_network_interface.rb"
require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/resource_win_network_interface.rb"
require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/provider_win_network_interface.rb"

# Load some fake libraries to represent ruby-wmi
module WMI
  class Win32_NetworkAdapter; end
  class Win32_NetworkAdapterConfiguration; end
end

# rubocop:disable Documentation
describe Chef::Provider::NetworkInterface::Win do
  # Create a provider instance
  let(:provider) { Chef::Provider::NetworkInterface::Win.new(new_resource, run_context) }

  # Some Chef stubbing
  let(:node) do
    node = Chef::Node.new
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }

  # Set current_resource and new_resource state
  let(:new_resource) do
    r = Chef::Resource::NetworkInterface::Win.new('eth1')
    r.index 8
    r
  end
  let(:current_resource) do
    r = Chef::Resource::NetworkInterface::Win.new('eth1')
    r.bootproto 'dhcp'
    r
  end

  let(:adapter) { double('WMI::Win32_NetworkAdapter', InterfaceIndex: 10, NetConnectionID: 'eth0') }
  let(:adapter_config) { double('Win32_NetworkAdapterConfiguration') }

  # Tie some things together
  before do
    allow(provider).to receive(:load_current_resource).and_return(current_resource)
    provider.new_resource = new_resource
    provider.current_resource = current_resource
    allow(run_context).to receive(:include_recipe).and_return(nil)
    allow(WMI::Win32_NetworkAdapterConfiguration).to receive(:find).and_return([adapter_config])
    allow(WMI::Win32_NetworkAdapter).to receive(:find).and_return([adapter])
  end

  describe '#action_create' do
    it 'renames the physical interface' do
      current_resource.device 'eth0'
      expect(adapter).to receive(:NetConnectionID=).with('eth1')
      expect(adapter).to receive(:Put_)
      provider.action_create
    end

    it 'appends -NIC to physical adapter name whe configuring VLANs' do
      current_resource.device 'eth1'
      new_resource.vlan 12
      expect(adapter).to receive(:NetConnectionID=).with('eth1-NIC')
      expect(adapter).to receive(:Put_)
      provider.action_create
    end

    it 'does not rename a physical adapter with correct name' do
      expect(adapter).not_to receive(:NetConnectionID=)
      expect(adapter).not_to receive(:Put_)
      provider.action_create
    end

    it 'configures DHCP on the interface' do
      current_resource.bootproto 'static'
      expect(adapter_config).to receive(:EnableDhcp)
      provider.action_create
    end

    it 'does nothing if DHCP is already configured' do
      current_resource.bootproto 'dhcp'
      expect(adapter_config).not_to receive(:EnableDhcp)
      provider.action_create
    end

    it 'configures static IP on the interface' do
      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'
      expect(adapter_config).to receive(:EnableStatic).with(['10.10.10.12'], ['255.255.254.0'])
      provider.action_create
    end

    it 'does not configure static IP if already configured' do
      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'
      current_resource.bootproto 'static'
      current_resource.address '10.10.10.12'
      current_resource.netmask '255.255.254.0'
      expect(adapter_config).not_to receive(:EnableStatic)
      provider.action_create
    end

    it 'does not configure static IP when DHCP is defined' do
      allow(adapter_config).to receive(:EnableDhcp)

      current_resource.bootproto 'static'
      expect(adapter_config).not_to receive(:EnableStatic)
      provider.action_create
    end

    it 'does not configure DHCP when static IP is defined' do
      allow(adapter_config).to receive(:EnableStatic)

      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'
      expect(adapter_config).not_to receive(:EnableDhcp)
      provider.action_create
    end

    it 'configures the gateway' do
      new_resource.bootproto 'static'
      new_resource.gateway '10.10.10.1'
      expect(adapter_config).to receive(:SetGateways).with('10.10.10.1')
      provider.action_create
    end

    it 'does not configure gateway if already properly configured' do
      new_resource.bootproto 'static'
      new_resource.gateway '10.10.10.1'
      current_resource.bootproto 'static'
      current_resource.gateway '10.10.10.1'
      expect(adapter_config).not_to receive(:SetGateways)
      provider.action_create
    end

    it 'does not configure gateway with DHCP defined' do
      new_resource.gateway '10.10.10.1'
      expect(adapter_config).not_to receive(:SetGateways)
      provider.action_create
    end

    it 'configures DNS' do
      current_resource.dns ['dns2', 'dns1']
      new_resource.dns ['dns1', 'dns2']
      expect(adapter_config).to receive(:SetDNSServerSearchOrder).with(['dns1', 'dns2'])
      provider.action_create
    end

    it 'does nothing if DNS already configured' do
      current_resource.dns ['dns1', 'dns2']
      new_resource.dns ['dns1', 'dns2']
      expect(adapter_config).not_to receive(:SetDNSServerSearchOrder)
      provider.action_create
    end

    it 'enables dynamic dns registration' do
      new_resource.ddns true
      expect(adapter_config).to receive(:SetDynamicDNSRegistration).with(true)
      provider.action_create
    end

    it 'disables dynamic dns registration' do
      new_resource.ddns false
      expect(adapter_config).to receive(:SetDynamicDNSRegistration).with(false)
      provider.action_create
    end

    it 'does nothing if dynamic DNS registration is properly configured' do
      new_resource.ddns true
      current_resource.ddns true
      expect(adapter_config).not_to receive(:SetDynamicDNSRegistration)
      provider.action_create
    end

    it 'configures DNS suffix search order' do
      new_resource.dns_search ['sub1.test.com', 'sub2.test.com']
      expect(adapter_config).to receive(:SetDNSSuffixSearchOrder).with(['sub1.test.com', 'sub2.test.com'])
      provider.action_create
    end

    it 'does nothing if DNS search order is correct' do
      new_resource.dns_search ['sub1.test.com', 'sub2.test.com']
      current_resource.dns_search ['sub1.test.com', 'sub2.test.com']
      expect(adapter_config).not_to receive(:SetDNSSuffixSearchOrder)
      provider.action_create
    end
  end
end
