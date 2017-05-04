require 'spec_helper'

describe 'fake::dhcp' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['network_interface']).converge(described_recipe)
    end

    it 'configure dhcp' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth1').with_content('BOOTPROTO="dhcp"')
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['network_interface']).converge(described_recipe)
    end

    it 'configure dhcp' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth1').with_content('iface eth1 inet dhcp')
    end
  end
end
