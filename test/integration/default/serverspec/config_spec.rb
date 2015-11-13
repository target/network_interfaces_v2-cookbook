require 'spec_helper'

if rhel?
  describe file("/etc/sysconfig/network-scripts/ifcfg-#{int['0']}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "ifcfg-#{int['0']}") }
  end
  describe file("/etc/sysconfig/network-scripts/ifcfg-#{int['4']}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "ifcfg-#{int['4']}") }
  end
end

if debian?
  describe file("/etc/network/interfaces.d/#{int['0']}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "#{int['0']}") }
  end
  describe file("/etc/network/interfaces.d/#{int['4']}") do
    it { should be_file }
    its(:content) { should eq File.read File.join(File.dirname(__FILE__), 'fixtures', "#{int['4']}") }
  end
end
