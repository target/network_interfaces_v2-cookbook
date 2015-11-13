require 'spec_helper'

describe 'fake::dns' do
  describe 'rhel family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['network_interface']).converge(described_recipe)
    end

    it 'configure dns' do
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth1').with_content('DNS1="14.14.13.13"')
      expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth1').with_content('DNS2="14.14.14.13"')
    end
  end
end
