require 'spec_helper'

unless windows?
  describe 'creates network configuration files' do
    describe interface('eth0') do
      it { should exist }
    end
    describe interface('eth1') do
      it { should exist }
      it { should have_ipv4_address '10.12.10.11' } if rhel?
      it { should have_ipv4_address '10.12.10.12' } if debian?
    end
    describe interface('eth2') do
      it { should exist }
    end
  end
end

if windows?
  describe 'Interface "eth1"' do
    it 'should exist' do
      expect(win_interface 'eth1').not_to be_nil
    end
  end

  describe 'Interface "eth2"' do
    it 'should exist' do
      expect(win_interface 'eth2').not_to be_nil
    end
  end
end
