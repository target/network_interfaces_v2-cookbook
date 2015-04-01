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
    it 'renames an adapter to eth1' do
      expect(win_interface 'eth1').not_to be_nil
    end

    it 'renames an adapter to eth2' do
      expect(win_interface 'eth2').not_to be_nil
    end
  end
end
