require 'spec_helper'

describe 'fake::metrics' do
  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface']).converge(described_recipe)
    end

    it 'installs packages required for vlan config on interface' do
      expect(chef_run).to install_package 'ifmetric'
    end

    it 'configures device for vlan' do
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content('metric 25')
    end
  end
end
