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

DEVICE="eth2"
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

    it 'creates interface eth1' do
      expect(chef_run).to create_network_interface 'eth1'
    end

    it 'creates interface eth2' do
      expect(chef_run).to create_rhel_network_interface 'eth2'
      expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth2'
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content(default_config_contents)
    end

    it 'does not reload interface by default' do
      expect(chef_run).not_to run_execute('reload interface eth2')
    end

    it 'it reloads eth2 interface after deploying config' do
      resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth2')
      expect(resource).to notify('execute[reload interface eth2]').to(:run).immediately
    end

    it 'logs having created interface eth2' do
      expect(chef_run).to write_log('rhel_network_interface[eth2] created eth2')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['debian_network_interface']) do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    let(:default_config_contents) do
'# This file maintained by Chef.  DO NOT EDIT!

auto eth2
iface eth2 inet dhcp
'
    end

    it 'creates directory for interface config files' do
      expect(chef_run).to create_directory '/etc/network/interfaces.d'
    end

    it 'removes unmanaged files from interface config directory' do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with('/etc/network/interfaces.d/*').and_return(['/etc/network/interfaces.d/eth1', '/etc/network/interfaces.d/eth13'])
      expect(chef_run).not_to delete_file '/etc/network/interfaces.d/eth1'
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

    it 'creates interface eth1' do
      expect(chef_run).to create_network_interface 'eth1'
    end

    it 'creates interface eth2' do
      expect(chef_run).to create_debian_network_interface 'eth2'
      expect(chef_run).to create_template '/etc/network/interfaces.d/eth2'
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content(default_config_contents)
    end

    it 'does not reload interface by default' do
      expect(chef_run).not_to run_execute('reload interface eth2')
    end

    it 'it reloads eth2 interface after deploying config' do
      resource = chef_run.template('/etc/network/interfaces.d/eth2')
      expect(resource).to notify('execute[reload interface eth2]').to(:run).immediately
    end

    it 'logs having created interface eth2' do
      expect(chef_run).to write_log('debian_network_interface[eth2] created eth2')
    end
  end
end
