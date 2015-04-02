require 'spec_helper'

unless windows?
  describe 'Interface "eth0"' do
    it 'should exist' do
      expect(interface 'eth0').to exist
    end

    it 'should have DHCP enabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).to contain(/[-\.]eth0./)
    end
  end

  describe 'Interface "eth1"' do
    it 'should exist' do
      expect(interface 'eth1').to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]eth1./)
    end

    it 'should have an address' do
      expect(interface('eth1').has_ipv4_address?('10.12.10.11')).to eq true if rhel?
      expect(interface('eth1').has_ipv4_address?('10.12.10.12')).to eq true if debian?
    end

    it 'should have netmask "255.255.255.0"' do
      expect(command('ip addr show dev eth1').stdout).to contain '/24 brd '
    end
  end

  describe 'Interface "eth2"' do
    it 'should exist' do
      expect(interface 'eth2').to exist
    end

    it 'should have DHCP enabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).to contain(/[-\.]eth2./)
    end
  end
end

if windows?
  describe 'Interface "eth1"' do
    it 'should exist' do
      expect(win_interface 'eth1').not_to be_nil
    end

    it 'should have DHCP disabled' do
      expect(win_interface_config('eth1')['dhcpenabled']).to eq false
    end

    it 'should have address "10.12.10.13"' do
      expect(win_interface_config('eth1')['ipaddress'].first).to eq '10.12.10.13'
    end

    it 'should have netmask "255.255.255.0"' do
      expect(win_interface_config('eth1')['ipsubnet'].first).to eq '255.255.255.0'
    end

    it 'should have gateway "10.12.10.1"' do
      expect(win_interface_config('eth1')['defaultipgateway'].first).to eq '10.12.10.1'
    end
  end

  describe 'Interface "eth2"' do
    it 'should exist' do
      expect(win_interface 'eth2').not_to be_nil
    end

    it 'should have DHCP enalbed' do
      expect(win_interface_config('eth2')['dhcpenabled']).to eq true
    end
  end
end
