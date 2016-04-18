require 'spec_helper'

unless windows?
  describe 'Interface "bond0"' do
    it 'should exist' do
      expect(bond('bond0')).to exist
    end

    it "should include #{int['5']} as a slave" do
      expect(bond('bond0').has_interface?(int['5'])).to eq true
    end

    it "should include #{int['6']} as a slave" do
      expect(bond('bond0').has_interface?(int['6'])).to eq true
    end
  end
end
