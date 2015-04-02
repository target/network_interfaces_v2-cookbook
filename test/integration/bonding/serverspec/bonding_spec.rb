require 'spec_helper'

describe 'Interface "bond0"' do
  it 'should exist' do
    expect(bond 'bond0').to exist
  end

  it 'should include eth1 as a slave' do
    expect(bond('bond0').has_interface? 'eth1').to eq true
  end

  it 'should include eth2 as a slave' do
    expect(bond('bond0').has_interface? 'eth2').to eq true
  end
end
