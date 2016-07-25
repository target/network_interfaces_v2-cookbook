require 'spec_helper'

describe 'fake::multiple_int_defs' do
  context 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.10', step_into: ['debian_network_interface', 'network_interface']).converge(described_recipe)
    end

    context 'eth0 inet4 config' do
      it 'does not set ipv6' do
        expect(chef_run).to create_network_interface('eth0_inet4').with(ipv6: false)
        expect(chef_run).to render_file('/etc/network/interfaces.d/eth0_inet4').with_content ' eth0 inet '
      end
    end

    context 'eth0 inet6 config' do
      it 'sets ipv6' do
        expect(chef_run).to create_network_interface('eth0_inet6').with(ipv6: true)
        expect(chef_run).to render_file('/etc/network/interfaces.d/eth0_inet6').with_content ' eth0 inet6 '
      end
    end
  end
end
