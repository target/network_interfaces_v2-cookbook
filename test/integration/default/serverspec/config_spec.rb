require 'spec_helper'

int0 = 'eth0'
int1 = 'eth1'
int2 = 'eth2'

# RHEL/CentOS 7+
if rhel? && rhel_version.split('.').first.to_i > 6
  int0 = 'enp0s3'
  int1 = 'enp0s8'
  int2 = 'enp0s9'
end

if rhel?
  describe file("/etc/sysconfig/network-scripts/ifcfg-#{int0}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "ifcfg-#{int0}") }
  end
  describe file("/etc/sysconfig/network-scripts/ifcfg-#{int1}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "ifcfg-#{int1}") }
  end
  describe file("/etc/sysconfig/network-scripts/ifcfg-#{int2}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "ifcfg-#{int2}") }
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
