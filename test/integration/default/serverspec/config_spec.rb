require 'spec_helper'

describe 'creates network configuration files' do
  if rhel?
    context 'rhel family' do
      describe file('/etc/sysconfig/network-scripts/ifcfg-eth0') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth0') }
      end
      describe file('/etc/sysconfig/network-scripts/ifcfg-eth1') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth1') }
      end
      describe file('/etc/sysconfig/network-scripts/ifcfg-eth2') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth2') }
      end
    end
  end

  if debian?
    context 'debian family' do
      describe file('/etc/network/interfaces.d/eth0') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth0') }
      end
      describe file('/etc/network/interfaces.d/eth1') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth1') }
      end
      describe file('/etc/network/interfaces.d/eth2') do
        it { should be_file }
        it { should contain File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth2') }
      end
    end
  end
end
