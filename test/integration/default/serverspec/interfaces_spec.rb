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

unless windows?
  describe "Interface '#{int0}'" do
    it 'should exist' do
      expect(interface int0).to exist
    end

    it 'should have DHCP enabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).to contain(/[-\.]#{int0}./)
    end
  end

  describe "Interface '#{int1}'" do
    it 'should exist' do
      expect(interface int1).to exist
    end

    it 'should have DHCP disabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).not_to contain(/[-\.]#{int1}./)
    end

    it 'should have an address' do
      expect(interface(int1).has_ipv4_address?('10.12.10.11')).to eq true if rhel?
      expect(interface(int1).has_ipv4_address?('10.12.10.12')).to eq true if debian?
    end

    it 'should have netmask "255.255.255.0"' do
      expect(command("ip addr show dev #{int1}").stdout).to contain '/24 brd '
    end
  end

  describe "Interface '#{int2}'" do
    it 'should exist' do
      expect(interface int2).to exist
    end

    it 'should have DHCP enabled' do
      expect(command('ps -ef | grep dhclient | grep -v grep').stdout).to contain(/[-\.]#{int2}./)
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

    # Get index in array of our found IP ... so we can match proper subnet later
    addr_indx = win_interface_config('eth1')['ipaddress'].index('10.12.10.13')

    it 'should have address "10.12.10.13"' do
      expect(win_interface_config('eth1')['ipaddress']).to include '10.12.10.13'
    end

    it 'should have netmask "255.255.255.0"' do
      subnet_ip = nil
      subnet_ip = win_interface_config('eth1')['ipsubnet'][addr_indx] unless addr_indx.nil?
      expect(subnet_ip).to eq '255.255.255.0'
    end

    it 'should have gateway "10.12.10.1"' do
      expect(win_interface_config('eth1')['defaultipgateway'].first).to eq '10.12.10.1'
    end

    it 'should have NetBIOS disabled' do
      expect(win_interface_config('eth1')['tcpipnetbiosoptions']).to eq 2
    end
  end

  describe 'Interface "eth2"' do
    it 'should exist' do
      expect(win_interface 'eth2').not_to be_nil
    end

    it 'should have DHCP enabled' do
      expect(win_interface_config('eth2')['dhcpenabled']).to eq true
    end

    it 'should have DNS servers assigned' do
      expect(win_interface_config('eth2')['dnsserversearchorder']).to eq ['14.13.13.13', '14.13.13.12']
    end

    it 'should have DNS domain set' do
      expect(win_interface_config('eth2')['dnsdomain']).to eq 'test.it.com'
    end

    it 'should have NetBIOS enabled' do
      expect(win_interface_config('eth2')['tcpipnetbiosoptions']).to eq 1
    end
  end

  describe 'Interface "Ethernet 4"' do
    it 'should have DHCP disabled' do
      expect(win_interface_config('Ethernet 4')['dhcpenabled']).to eq false
    end

    it 'should have an address' do
      expect(win_interface_config('Ethernet 4')['ipaddress'].first).to match(/172.28.128.[0-9]+/)
    end

    it 'should have netmask "255.255.255.0"' do
      expect(win_interface_config('Ethernet 4')['ipsubnet'].first).to eq '255.255.255.0'
    end
  end
end
