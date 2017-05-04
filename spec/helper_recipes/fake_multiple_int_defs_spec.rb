require 'spec_helper'

describe 'fake::multiple_int_defs' do
  context 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface', 'network_interface']).converge(described_recipe)
    end

    context 'eth9 inet4 config' do
      it 'does not set ipv6' do
        expect(chef_run).to create_network_interface('eth9_inet4').with(ipv6: false)
        expect(chef_run).to render_file('/etc/network/interfaces.d/eth9_inet4').with_content ' eth9 inet '
      end
    end

    context 'eth9 inet6 config' do
      it 'sets ipv6' do
        expect(chef_run).to create_network_interface('eth9_inet6').with(ipv6: true)
        expect(chef_run).to render_file('/etc/network/interfaces.d/eth9_inet6').with_content ' eth9 inet6 '
      end
    end
  end
end
