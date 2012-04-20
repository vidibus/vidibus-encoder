require 'spec_helper'

class Base
  include Vidibus::Encoder::Helper::Tools
end

describe Vidibus::Encoder::Helper::Tools do
  let(:base) {Base.new}
  let(:input) do
    stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
    util = Vidibus::Encoder::Util::Input.new(:path => 'whatever', :base => base)
    stub(util).properties do
      { :frame_rate => 25 }
    end
    util
  end

  before do
    stub(base).input { input }
  end

  describe '#matching_frame_rate' do
    it 'should require an argument' do
      expect { base.matching_frame_rate }.to raise_error(ArgumentError)
    end

    it 'should require an array' do
      expect { base.matching_frame_rate('whatever') }.
        to raise_error(ArgumentError, 'Argument must be an array')
    end

    it 'return a frame rate that matches input perfectly' do
      base.matching_frame_rate([25]).should eq(25)
    end

    it 'return a frame rate that matches input perfectly from given alternatives' do
      base.matching_frame_rate([29.97, 25]).should eq(25)
    end

    it 'should return a frame rate that is a divisor of input' do
      base.matching_frame_rate([2.5]).should eq(2.5)
    end

    it 'should return the largest divisor' do
      base.matching_frame_rate([2.5, 5]).should eq(5)
    end

    it 'should return nil if no alternative matches' do
      base.matching_frame_rate([29.97, 10]).should be_nil
    end
  end
end
