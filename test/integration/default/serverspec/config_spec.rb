require 'spec_helper'

describe 'creates network configuration files' do
  if rhel?
    context 'rhel family' do
      it 'creates config for eth0' do
        expect(file('/etc/sysconfig/network-scripts/ifcfg-eth0')).to be_file
      end
      it 'creates config for eth1' do
        expect(file('/etc/sysconfig/network-scripts/ifcfg-eth1')).to be_file
      end
      it 'creates config for eth2' do
        expect(file('/etc/sysconfig/network-scripts/ifcfg-eth2')).to be_file
      end
    end
  end

  if debian?
    context 'debian family' do
      it 'creates config for eth0' do
        expect(file('/etc/network/interfaces.d/eth0')).to be_file
      end
      it 'creates config for eth1' do
        expect(file('/etc/network/interfaces.d/eth1')).to be_file
      end
      it 'creates config for eth2' do
        expect(file('/etc/network/interfaces.d/eth2')).to be_file
      end
    end
  end
end
