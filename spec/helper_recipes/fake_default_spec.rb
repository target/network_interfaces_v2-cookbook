require 'spec_helper'

describe 'fake::default' do
  describe 'rhel family' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['rhel_network_interface']) do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    let(:default_config_contents) do
'# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth11"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="dhcp"
NM_CONTROLLED="off"
'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vconfig'
      expect(chef_run).not_to install_package 'iputils'
    end

    it 'creates interface eth10' do
      expect(chef_run).to create_network_interface 'eth10'
    end

    it 'creates interface eth11' do
      expect(chef_run).to create_rhel_network_interface 'eth11'
      expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth11'
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth11').with_content(default_config_contents)
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['debian_network_interface']) do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    it 'creates directory for interface config files' do
      expect(chef_run).to create_directory '/etc/network/interfaces.d'
    end

    it 'removes unmanaged files from interface config directory' do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with('/etc/network/interfaces.d/*').and_return(['/etc/network/interfaces.d/eth10', '/etc/network/interfaces.d/eth13'])
      expect(chef_run).not_to delete_file '/etc/network/interfaces.d/eth10'
      expect(chef_run).to delete_file '/etc/network/interfaces.d/eth13'
    end

    it 'replaces main network config file to reference interface configs' do
      expect(chef_run).to create_cookbook_file '/etc/network/interfaces'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vlan'
      expect(chef_run).not_to install_package 'ifenslave-2.6'
      expect(chef_run).not_to install_package 'ifmetric'
      expect(chef_run).not_to install_package 'bridge-utils'
    end

    it 'does not load any modules' do
      expect(chef_run).not_to save_modules '8021q'
      expect(chef_run).not_to save_modules 'bonding'
    end

    it 'creates interface eth10' do
      expect(chef_run).to create_network_interface 'eth10'
    end

    it 'creates interface eth11' do
      expect(chef_run).to create_debian_network_interface 'eth11'
      expect(chef_run).to create_template '/etc/network/interfaces.d/eth11'
    end
  end
end
