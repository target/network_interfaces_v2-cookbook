require 'spec_helper'
unless windows?
  describe 'Interface "br0"' do
    it 'should exist' do
      expect(interface('br0')).to exist
    end

    it "should include #{int['7']} as an interface" do
      expect(command("brctl show br0 | egrep #{int['7']}$").exit_status).to eq 0
    end

    it 'should have an address set' do
      expect(interface('br0').has_ipv4_address?('13.13.13.10')).to eq true
    end

    it 'should have netmask set' do
      expect(command('ip addr show dev br0').stdout).to contain '/24 brd '
    end
  end
end
