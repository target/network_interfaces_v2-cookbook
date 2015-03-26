require 'spec_helper'

describe 'fake::override' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['rhel_network_interface']) do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    it 'properly sets type attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('TYPE="IPsec"')
    end

    it 'properly sets bootproto attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('BOOTPROTO="static"')
    end

    it 'properly sets address attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('IPADDR="12.12.12.12"')
    end

    it 'properly sets netmask attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('NETMASK="255.255.255.0"')
    end

    it 'properly sets network attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('NETWORK="12.12.12.0"')
    end

    it 'properly sets broadcast attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('BROADCAST="12.12.12.255"')
    end

    it 'properly sets gateway attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('GATEWAY="12.12.12.1"')
    end

    it 'properly sets bond_master attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('MASTER="eth0"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('SLAVE="yes"')
    end

    it 'properly sets hw_address attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('HWADDR="13-13-13-13-13-13"')
    end

    it 'properly sets mac_address attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('MACADDR="12-12-12-12-12-12"')
    end

    it 'properly sets bond_mode attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('BONDING_OPTS="test opts"')
    end

    it 'properly sets bridge attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('BRIDGE="eth0"')
    end

    it 'properly sets bridge_stp attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('STP="off"')
    end

    it 'properly sets mtu attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('MTU="1501"')
    end

    it 'properly sets nm_controlled attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('NM_CONTROLLED="on"')
    end

    it 'properly sets ipv6init attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('IPV6INIT="off"')
    end

    it 'properly sets nozeroconf attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('NOZEROCONF="on"')
    end

    it 'properly sets userctl attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('USERCTL="off"')
    end

    it 'properly sets peerdns attribtue in config' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('PEERDNS="on"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['debian_network_interface']) do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    it 'properly sets address attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  address 12.12.12.12')
    end

    it 'properly sets netmask attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  netmask 255.255.255.0')
    end

    it 'properly sets broadcast attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  broadcast 12.12.12.255')
    end

    it 'properly sets gateway attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  gateway 12.12.12.1')
    end

    it 'properly sets bridge_ports attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  bridge_ports eth3 eth4')
    end

    it 'properly sets bridge_stp attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  bridge_stp off')
    end

    it 'properly sets bond_slaves attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  bond-slaves eth0 eth1')
    end

    it 'properly sets bond_mode attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  bond-mode test mode')
    end

    it 'properly sets mtu attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  mtu 1501')
    end

    it 'properly sets pre_up attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  pre-up pre up code')
    end

    it 'properly sets up attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  up code for up')
    end

    it 'properly sets post_up attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  post-up post up it')
    end

    it 'properly sets pre_down attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  pre-down pre down plz')
    end

    it 'properly sets down attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  down coming down')
    end

    it 'properly sets post_down attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  post-down im down')
    end

    it 'properly sets custom attribtue in config' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  abc 123')
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('  custom_attr custom_command')
    end
  end
end
