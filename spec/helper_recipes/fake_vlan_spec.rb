require 'spec_helper'

describe 'fake::vlan' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface']) do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'vconfig'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth8.12').with_content('VLAN="yes"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface']).converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'vlan'
    end

    it 'loads modules required for vlan config on interface' do
      expect(chef_run).to install_kernel_module '8021q'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth8.12').with_content('vlan-raw-device eth8')
    end
  end
end
