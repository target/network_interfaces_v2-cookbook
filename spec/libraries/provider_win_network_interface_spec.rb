require 'spec_helper'

require 'chef/platform'
require 'chef/run_context'
require 'chef/resource'
require 'chef/event_dispatch/base'
require 'chef/event_dispatch/dispatcher'

require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/resource_win_network_interface.rb"
require "#{File.join(File.dirname(__FILE__), '..', '..', 'libraries')}/provider_win_network_interface.rb"

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

  let(:adapter) do
    double('WMI::Win32_NetworkAdapter', InterfaceIndex: 10, NetConnectionID: 'eth1', enable: nil, disable: nil)
  end
  let(:adapter_config) do
    double('Win32_NetworkAdapterConfiguration', IPAddress: ['12.13.14.15', '10.10.10.10', 'asdf:asdf:asdf:asdf'],
                                                IPSubnet: ['255.255.254.0', '255.255.255.0', '64'],
                                                DefaultIPGateway: ['10.10.10.1'],
                                                DNSServerSearchOrder: [],
                                                FullDNSRegistrationEnabled: false,
                                                DNSDomainSuffixSearchOrder: [],
                                                DHCPEnabled: false,
                                                DNSDomain: '',
                                                TCPIPNetbiosOptions: 0)
  end

  let(:shellout) { double('Mixlib::ShellOut', run_command: nil, error!: nil) }

  # Tie some things together
  before do
    allow(provider).to receive(:sleep).and_return(nil) # Speed up testing
    provider.new_resource = new_resource
    provider.current_resource = current_resource

    allow(provider).to receive(:execute_wmi_query).with(/Win32_NetworkAdapter /).and_return([adapter])
    allow(provider).to receive(:execute_wmi_query).with(/Win32_NetworkAdapterConfiguration /).and_return([adapter_config])
  end

  describe '#load_current_resource' do
    it 'grabs the correct address' do
      provider.load_current_resource
      expect(provider.current_resource.addresses).to eq ['12.13.14.15', '10.10.10.10', 'asdf:asdf:asdf:asdf']
    end

    it 'grabs the correct netmask' do
      provider.load_current_resource
      expect(provider.current_resource.netmasks).to eq ['255.255.254.0', '255.255.255.0', '64']
    end
  end

  describe '#action_create' do
    it 'renames the physical interface' do
      allow(adapter).to receive(:NetConnectionID).and_return('eth0')
      current_resource.device 'eth0'
      expect(adapter).to receive(:NetConnectionID=).with('eth1')
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
      allow(adapter_config).to receive(:ReleaseDHCPLease)

      expect(adapter_config).to receive(:EnableStatic)
        .with(['10.10.10.12', '12.13.14.15', '10.10.10.10'], ['255.255.254.0', '255.255.254.0', '255.255.255.0'])
      provider.action_create
    end

    it 'releases DHCP address before setting IP' do
      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'

      expect(adapter_config).to receive(:ReleaseDHCPLease)
      expect(adapter_config).to receive(:EnableStatic)
      provider.action_create
    end

    it 'does not release DHCP address before setting IP if DHCP is already disabled' do
      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'

      current_resource.bootproto 'static'

      expect(adapter_config).not_to receive(:EnableDhcp)
      expect(adapter_config).not_to receive(:ReleaseDHCPLease)
      expect(adapter_config).to receive(:EnableStatic)
      provider.action_create
    end

    it 'configures static IP on the interface if IP is wrong' do
      current_resource.address '10.10.10.11'
      current_resource.netmask '255.255.254.0'
      current_resource.bootproto 'static'

      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'
      expect(adapter_config).to receive(:EnableStatic)
        .with(['10.10.10.12', '12.13.14.15', '10.10.10.10'], ['255.255.254.0', '255.255.254.0', '255.255.255.0'])
      provider.action_create
    end

    it 'configures static IP on the interface if netmask is wrong' do
      current_resource.address '10.10.10.12'
      current_resource.netmask '255.255.255.0'
      current_resource.bootproto 'static'

      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'
      expect(adapter_config).to receive(:EnableStatic)
        .with(['10.10.10.12', '12.13.14.15', '10.10.10.10'], ['255.255.254.0', '255.255.254.0', '255.255.255.0'])
      provider.action_create
    end

    it 'configures static IP on the interface if IP/netmask is correct but currently using DHCP' do
      allow(adapter_config).to receive(:ReleaseDHCPLease)
      allow(adapter_config).to receive(:EnableStatic)

      current_resource.address '10.10.10.12'
      current_resource.addresses = ['10.10.10.12', '12.13.14.15', '10.10.10.10']
      current_resource.netmasks = ['255.255.255.0', '255.255.254.0', '255.255.255.0']
      current_resource.netmask '255.255.255.0'
      current_resource.bootproto 'dhcp'

      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.255.0'
      expect(adapter_config).to receive(:EnableStatic)
        .with(['10.10.10.12', '12.13.14.15', '10.10.10.10'], ['255.255.255.0', '255.255.254.0', '255.255.255.0'])
      provider.action_create
    end

    it 'does not configure static IP if already configured' do
      new_resource.bootproto 'static'
      new_resource.address '10.10.10.12'
      new_resource.netmask '255.255.254.0'

      current_resource.bootproto 'static'
      current_resource.addresses = ['12.13.14.15', '10.10.10.12', 'asdf:asdf:asdf:asdf']
      current_resource.netmasks = ['255.255.255.0', '255.255.254.0', '64']

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
      allow(adapter_config).to receive(:ReleaseDHCPLease)
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
      expect(adapter_config).to receive(:SetGateways).with(['10.10.10.1'])
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
      current_resource.dns ['10.10.10.10', '10.10.10.11']
      new_resource.dns ['10.10.10.11', '10.10.10.10']
      expect(adapter_config).to receive(:SetDNSServerSearchOrder).with(['10.10.10.11', '10.10.10.10'])
      provider.action_create
    end

    it 'does nothing if DNS already configured' do
      current_resource.dns ['10.10.10.10', '10.10.10.11']
      new_resource.dns ['10.10.10.10', '10.10.10.11']
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

    it 'configures DNS domain' do
      new_resource.dns_domain 'my_dns_domain.com'
      expect(adapter_config).to receive(:SetDNSDomain).with('my_dns_domain.com')
      provider.action_create
    end

    it 'does nothing if DNS domain is set' do
      new_resource.dns_domain 'my_dns_domain.com'
      current_resource.dns_domain 'my_dns_domain.com'
      expect(adapter_config).not_to receive(:SetDNSDomain)
      provider.action_create
    end

    it 'reloads interface if changes made' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      expect(adapter).to receive(:disable)
      expect(adapter).to receive(:enable)
      provider.action_create
    end

    it 'does not reload interface if no changes made' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      current_resource.dns_domain 'my_dns_domain.com'
      expect(adapter).not_to receive(:disable)
      expect(adapter).not_to receive(:enable)
      provider.action_create
    end

    it 'does not reloads interface if defined by user' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      new_resource.reload false # Defined by user not to reload
      expect(adapter).not_to receive(:disable)
      expect(adapter).not_to receive(:enable)
      provider.action_create
    end

    it 'runs post script if changes made' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      new_resource.post_up 'test command'
      expect(provider) .to receive(:post_up).with('test command').and_call_original
      expect(Mixlib::ShellOut).to receive(:new).with("powershell.exe -Command 'test command'").and_return(shellout)
      provider.action_create
    end

    it 'does not run post script if no changes made' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      current_resource.dns_domain 'my_dns_domain.com'
      expect(provider).not_to receive(:post_up)
      provider.action_create
    end

    it 'does run post script if not defined by user' do
      allow(adapter_config).to receive(:SetDNSDomain)
      new_resource.dns_domain 'my_dns_domain.com'
      expect(provider).not_to receive(:post_up)
      provider.action_create
    end

    describe 'managing vlans' do
      let(:adapter) do
        double('WMI::Win32_NetworkAdapter', InterfaceIndex: 10, NetConnectionID: 'eth1-NIC', enable: nil, disable: nil)
      end
      let(:vlan_adapter) do
        double('WMI::Win32_NetworkAdapter (VLAN)', InterfaceIndex: 12, NetConnectionID: 'eth1', enable: nil, disable: nil)
      end
      let(:adapter_config) do
        double('Win32_NetworkAdapterConfiguration', IPAddress: ['12.13.14.15', '10.10.10.10', 'asdf:asdf:asdf:asdf'],
                                                    IPSubnet: ['255.255.254.0', '255.255.255.0', '64'],
                                                    DefaultIPGateway: ['10.10.10.1'],
                                                    DNSServerSearchOrder: ['my_dns_domain.com'],
                                                    FullDNSRegistrationEnabled: false,
                                                    DNSDomainSuffixSearchOrder: [],
                                                    DHCPEnabled: true,
                                                    DNSDomain: '',
                                                    TCPIPNetbiosOptions: 0)
      end
      let(:vlan_adapter_config) do
        double('Win32_NetworkAdapterConfiguration (VLAN)', IPAddress: ['12.13.14.15', '10.10.10.10', 'asdf:asdf:asdf:asdf'],
                                                           IPSubnet: ['255.255.254.0', '255.255.255.0', '64'],
                                                           DefaultIPGateway: ['10.10.10.1'],
                                                           DNSServerSearchOrder: [],
                                                           FullDNSRegistrationEnabled: false,
                                                           DNSDomainSuffixSearchOrder: [],
                                                           DHCPEnabled: true,
                                                           DNSDomain: '',
                                                           TCPIPNetbiosOptions: 0)
      end

      before do
        current_resource.device 'eth1-NIC'
        new_resource.vlan 12

        allow(provider).to receive(:vlan_dev_exist?).and_return(false)
        allow(provider).to receive(:msft_vlan_dev_exist?).and_return(false)
        allow(provider).to receive(:vlanid_set?).and_return(false)

        allow(provider).to receive(:create_vlan_dev)
        allow(provider).to receive(:set_vlan)
        allow(provider).to receive(:rename_vlan_dev)

        allow(provider).to receive(:execute_wmi_query).with(/Win32_NetworkAdapter /).and_return([adapter], [adapter], [vlan_adapter])
        allow(provider).to receive(:execute_wmi_query).with("select * from Win32_NetworkAdapterConfiguration where InterfaceIndex='12'").and_return([vlan_adapter_config])
      end

      it 'appends -NIC to physical adapter name whe configuring VLANs' do
        current_resource.device 'eth1'
        allow(adapter).to receive(:NetConnectionID).and_return('eth1')

        expect(adapter).to receive(:NetConnectionID=).with('eth1-NIC')
        expect(adapter).to receive(:Put_)
        provider.action_create
      end

      it 'creates a VLAN device' do
        expect(provider).to receive(:create_vlan_dev)
        provider.action_create
      end

      it 'does not create a VLAN device that already exists' do
        allow(provider).to receive(:vlan_dev_exist?).and_return(true)
        expect(provider).not_to receive(:create_vlan_dev)
        provider.action_create
      end

      it 'does not create a VLAN device that already exists with MSFT naming' do
        allow(provider).to receive(:msft_vlan_dev_exist?).and_return(true)
        expect(provider).not_to receive(:create_vlan_dev)
        provider.action_create
      end

      it 'sets VLAN ID on the device if not set' do
        expect(provider).to receive(:set_vlan)
        provider.action_create
      end

      it 'does not set VLAN ID on a device that has it set and has been renamed' do
        allow(provider).to receive(:vlanid_set?).and_return(true)
        expect(provider).not_to receive(:set_vlan)
        provider.action_create
      end

      it 'does not set VLAN ID on a device that has it set with a MSFT naming convention' do
        allow(provider).to receive(:msft_vlan_dev_exist?).and_return(true)
        expect(provider).not_to receive(:set_vlan)
        provider.action_create
      end

      it 'renames the VLAN device to what we want' do
        allow(provider).to receive(:msft_vlan_dev_exist?).and_return(true)
        expect(provider).to receive(:rename_vlan_dev)
        provider.action_create
      end

      it 'does not rename a properly named VLAN device' do
        expect(provider).not_to receive(:rename_vlan_dev)
        provider.action_create
      end

      it 'configures DNS on the VLAN device' do
        new_resource.dns_domain 'my_dns_domain.com'
        expect(vlan_adapter_config).to receive(:SetDNSDomain).with('my_dns_domain.com')
        provider.action_create
      end
    end
  end
end
