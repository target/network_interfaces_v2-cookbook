require 'spec_helper'

unless windows?
  describe 'creates network configuration files' do
    it 'eth0 is up' do
      expect(interface('eth0')).to exist
    end
    it 'eth1 is up' do
      expect(interface('eth1')).to exist
    end
    it 'eth2 is up' do
      expect(interface('eth2')).to exist
    end
  end
end

if windows?
  describe 'test' do
    it 'test test' do
      expect(port(3389)).to be_listening
    end
  end
end
