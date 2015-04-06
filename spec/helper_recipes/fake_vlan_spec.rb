require 'spec_helper'

describe 'fake::vlan' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['rhel_network_interface']) do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'vconfig'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content('VLAN="yes"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.10', step_into: ['debian_network_interface']).converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'vlan'
    end

    it 'loads modules required for vlan config on interface' do
      expect(chef_run).to save_modules '8021q'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2.12').with_content('vlan_raw_device eth2')
    end
  end
end
