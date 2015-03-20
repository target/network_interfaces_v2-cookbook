require 'spec_helper'

describe 'fake::default' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'does stuff' do
    chef_run
  end
end
