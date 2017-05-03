require 'spec_helper'

describe 'fake::bonding' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['network_interface']).converge(described_recipe)
    end

    it 'installs packages required for bonding config on interface' do
      expect(chef_run).to install_package 'iputils'
    end

    it 'configures slave devices for bonding' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth5').with_content('MASTER="bond0"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth5').with_content('SLAVE="yes"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth6').with_content('MASTER="bond0"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth6').with_content('SLAVE="yes"')
    end

    it 'configures bond device' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-bond0').with_content('BONDING_OPTS="mode=1 miimon=100"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface', 'network_interface']).converge(described_recipe)
    end

    it 'installs packages required for bonding config on interface' do
      expect(chef_run).to install_package 'ifenslave-2.6'
    end

    it 'loads modules required for bonding config on interface' do
      expect(chef_run).to install_kernel_module 'bonding'
    end

    it 'configures slave devices for bonding' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth5').with_content('  bond-master bond0')
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth6').with_content('  bond-master bond0')
    end

    it 'configures device for bonding' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/bond0').with_content('  bond-slaves eth5 eth6')
      expect(chef_run).to render_file('/etc/network/interfaces.d/bond0').with_content('  bond-mode 0')
    end
  end
end
