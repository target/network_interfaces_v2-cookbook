require 'spec_helper'

describe 'fake::default' do
  describe 'rhel family' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.automatic['platform_family'] = 'rhel'
      end.converge(described_recipe)
    end

    it 'creates interface eth10' do
      expect(chef_run).to create_network_interface 'eth10'
    end

    it 'creates interface eth11' do
      expect(chef_run).to create_rhel_network_interface 'eth11'
    end
  end

  describe 'debian family' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['debian_network_interface']) do |node|
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    it 'creates directory for interface config files' do
      expect(chef_run).to create_directory '/etc/network/interfaces.d'
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
