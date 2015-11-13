require 'spec_helper'

unless windows?
  int2 = 'eth2'

  # RHEL/CentOS 7+
  int2 = 'enp0s9' if rhel? && rhel_version.split('.').first.to_i > 6

  describe "Interface '#{int2}'" do
    it 'should exist' do
      expect(interface int2).to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]#{int2}\./)
    end
  end

  describe "Interface '#{int2}.12'" do
    it 'should exist' do
      expect(interface "#{int2}.12").to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]#{int2}\.12\./)
    end

    it 'should have an address' do
      expect(interface("#{int2}.12").has_ipv4_address?('12.12.12.12')).to eq true if rhel?
      expect(interface("#{int2}.12").has_ipv4_address?('12.12.12.13')).to eq true if debian?
    end

    it 'should have netmask "255.255.255.0"' do
      expect(command("ip addr show dev #{int2}.12").stdout).to contain '/24 brd '
    end
  end
end

if windows?
  describe 'Interface "eth2"' do
    it 'should exist' do
      expect(win_interface 'eth2').not_to be_nil
    end

    it 'should have DHCP disabled' do
      expect(win_interface_config('eth2')['dhcpenabled']).to eq false
    end

    it 'should have VLAN set' do
      expect(command("(Get-NetLbfoTeamNic -name 'eth2').VlanID").stdout.chomp).to eq '12'
    end

    it 'should have address "12.12.12.14"' do
      expect(win_interface_config('eth2')['ipaddress'].first).to eq '12.12.12.14'
    end

    it 'should have netmask "255.255.255.0"' do
      expect(win_interface_config('eth2')['ipsubnet'].first).to eq '255.255.255.0'
    end

    it 'should have DNS servers assigned' do
      expect(win_interface_config('eth2')['dnsserversearchorder']).to eq ['4.2.2.4', '4.2.2.8']
    end
  end
end
