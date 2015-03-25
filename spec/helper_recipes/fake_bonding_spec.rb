require 'spec_helper'

describe 'fake::bonding' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['rhel_network_interface']) do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    it 'installs packages required for bonding config on interface' do
      expect(chef_run).to install_package 'iputils'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('MASTER="eth0"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('SLAVE="yes"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('BONDING_OPTS="test opts"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['debian_network_interface']) do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'ifenslave-2.6'
    end

    it 'loads modules required for vlan config on interface' do
      expect(chef_run).to save_modules 'bonding'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('bond-slaves eth0 eth1')
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('bond-mode test mode')
    end
  end
end
