require 'spec_helper'

int1 = 'eth1'
int2 = 'eth2'

# RHEL/CentOS 7+
if rhel? && rhel_version.split('.').first.to_i > 6
  int1 = 'enp0s8'
  int2 = 'enp0s9'
end

describe 'Interface "bond0"' do
  it 'should exist' do
    expect(bond 'bond0').to exist
  end

  it "should include #{int1} as a slave" do
    expect(bond('bond0').has_interface? int1).to eq true
  end

  it "should include #{int2} as a slave" do
    expect(bond('bond0').has_interface? int2).to eq true
  end
end
