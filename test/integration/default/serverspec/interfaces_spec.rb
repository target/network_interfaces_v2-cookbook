require 'spec_helper'

unless windows?
  describe 'creates network configuration files' do
    describe interface('eth0') do
      it { should exist }
    end

    describe interface('eth2') do
      it { should exist }
    end

    # Check eth0 and eth2 are DHCP
    describe command('ps -ef | grep dhclient | grep -v grep') do
      its(:stdout) { should contain '-eth0.' } if rhel?
      its(:stdout) { should contain '.eth0.' } if debian?

      its(:stdout) { should contain '-eth2.' } if rhel?
      its(:stdout) { should contain '.eth2.' } if debian?
    end

    describe interface('eth1') do
      it { should exist }
      it { should have_ipv4_address '10.12.10.11' } if rhel?
      it { should have_ipv4_address '10.12.10.12' } if debian?
    end

    # Check netmask
    describe command('ip addr show dev eth1') do
      its(:stdout) { should contain '/24 brd ' }
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
