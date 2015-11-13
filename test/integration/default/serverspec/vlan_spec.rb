require 'spec_helper'

unless windows?
  describe "Interface '#{int['8']}'" do
    it 'should exist' do
      expect(interface int['8']).to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]#{int['8']}\./)
    end
  end

  describe "Interface '#{int['8']}.12'" do
    it 'should exist' do
      expect(interface "#{int['8']}.12").to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]#{int['8']}\.12\./)
    end

    it 'should have an address' do
      expect(interface("#{int['8']}.12").has_ipv4_address?('12.12.12.12')).to eq true
    end

    it 'should have netmask "255.255.255.0"' do
      expect(command("ip addr show dev #{int['8']}.12").stdout).to contain '/24 brd '
    end
  end
end

if windows?
  describe 'Interface "vlan12"' do
    it 'should exist' do
      expect(win_interface 'vlan12').not_to be_nil
    end

    it 'should have DHCP disabled' do
      expect(win_interface_config('vlan12')['dhcpenabled']).to eq false
    end

    it 'should have VLAN set' do
      expect(command("(Get-NetLbfoTeamNic -name 'vlan12').VlanID").stdout.chomp).to eq '12'
    end

    it 'should have address "12.12.12.14"' do
      expect(win_interface_config('vlan12')['ipaddress'].first).to eq '12.12.12.14'
    end

    it 'should have netmask "255.255.255.0"' do
      expect(win_interface_config('vlan12')['ipsubnet'].first).to eq '255.255.255.0'
    end

    it 'should have DNS servers assigned' do
      expect(win_interface_config('vlan12')['dnsserversearchorder']).to eq ['4.2.2.4', '4.2.2.8']
    end
  end
end
