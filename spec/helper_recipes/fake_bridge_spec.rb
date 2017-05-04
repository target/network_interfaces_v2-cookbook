require 'spec_helper'

describe 'fake::bridge' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface']).converge(described_recipe)
    end

    it 'installs packages required for bridge config on interface' do
      expect(chef_run).to install_package 'bridge-utils'
    end

    it 'configures interfaces as bridge members' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth7').with_content('BRIDGE="br0"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface']).converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'bridge-utils'
    end

    it 'configures device for bridging' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/br0').with_content('  bridge_ports eth7')
    end

    it 'disables bridge stp' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/br0').with_content('  bridge_stp off')
    end
  end
end
