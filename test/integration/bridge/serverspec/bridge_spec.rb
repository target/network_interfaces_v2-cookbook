require 'spec_helper'

int1 = 'eth1'

# RHEL/CentOS 7+
int1 = 'enp0s8' if rhel? && rhel_version.split('.').first.to_i > 6

describe 'Interface "br0"' do
  it 'should exist' do
    expect(interface 'br0').to exist
  end

  it "should include #{int1} as an interface" do
    expect(command("brctl show br0 | egrep #{int1}$").exit_status).to eq 0
  end

  it 'should have an address set' do
    expect(interface('br0').has_ipv4_address?('13.13.13.10')).to eq true if rhel?
    expect(interface('br0').has_ipv4_address?('13.13.13.11')).to eq true if debian?
  end

  it 'should have netmask set' do
    expect(command('ip addr show dev br0').stdout).to contain '/24 brd '
  end
end
