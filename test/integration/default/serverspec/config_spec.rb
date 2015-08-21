require 'spec_helper'

if rhel?
  describe file('/etc/sysconfig/network-scripts/ifcfg-eth0') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth0') }
  end
  describe file('/etc/sysconfig/network-scripts/ifcfg-eth1') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth1') }
  end
  describe file('/etc/sysconfig/network-scripts/ifcfg-eth2') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'ifcfg-eth2') }
  end
end

if debian?
  describe file('/etc/network/interfaces.d/eth0') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth0') }
  end
  describe file('/etc/network/interfaces.d/eth1') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth1') }
  end
  describe file('/etc/network/interfaces.d/eth2') do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', 'eth2') }
  end
end
