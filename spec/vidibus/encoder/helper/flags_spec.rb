require 'spec_helper'

class Dummy
  extend Vidibus::Encoder::Helper::Flags
end

class MyDummy < Dummy
end

describe Vidibus::Encoder::Helper::Flags do
  describe '#flag' do
    it 'should fail without arguments' do
      expect { Dummy.flag }.to raise_error(ArgumentError)
    end

    it 'should fail without a block' do
      expect { Dummy.flag(:test) }.to raise_error(ArgumentError, 'Block is missing')
    end

    it 'should fail without a block' do
      Dummy.flag(:test) { |value| "-v #{value}" }
    end

    it 'should work with a block' do
      expect { Dummy.flag(:test) { |value| "-v #{value}" } }.not_to raise_error
    end

    context 'with proper arguments' do
      before do
        Dummy.flag(:test) { |value| "-v #{value}" }
      end

      it 'should register the flag handler' do
        Dummy.registered_flags[:test].should be_a(Proc)
      end

      it 'should produce a working handler' do
       Dummy.registered_flags[:test].call(123).should eql('-v 123')
      end
    end

    context 'on a sub-class' do
      it 'should work' do
        MyDummy.flag(:test) { |value| "-v #{value}" }
        MyDummy.registered_flags[:test].call(123).should eql('-v 123')
      end
    end
  end
end
