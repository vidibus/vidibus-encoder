require 'spec_helper'

describe Vidibus::Encoder::Util::Input do
  describe 'initializing' do
    it 'should fail without arguments' do
      expect { Vidibus::Encoder::Util::Input.new }.to
        raise_error(ArgumentError)
    end

    it 'should require a :name' do
      expect { Vidibus::Encoder::Util::Input.new(:what => 'ever') }.to
        raise_error(ArgumentError, 'Define a name for this profile')
    end

    it 'should fail if :name is blank' do
      expect { Vidibus::Encoder::Util::Input.new(:name => '') }.to
        raise_error(ArgumentError, 'Define a name for this profile')
    end

    it 'should require :settings' do
      expect { Vidibus::Encoder::Util::Input.new(:name => 'some') }.to
        raise_error(ArgumentError, 'Define a settings hash for this profile')
    end

    it 'should fail if :settings is not a Hash' do
      expect { Vidibus::Encoder::Util::Input.new(:name => 'some', :settings => 'whatever') }.to
        raise_error(ArgumentError, 'Define a settings hash for this profile')
    end

    it 'should fail if :settings are empty' do
      expect { Vidibus::Encoder::Util::Input.new(:name => 'some', :settings => {}) }.to
        raise_error(ArgumentError, 'Define a settings hash for this profile')
    end

    it 'should analyze input' do
      pending
      mock.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
      # base.input = 'input'
    end
  end

  describe '#to_s' do
    it 'should be spec\'d'
  end

  describe '#readable?' do
    it 'should be spec\'d'
  end

  describe '#validate' do
    it 'should be spec\'d'
  end

  describe '#validate' do
    it 'should be spec\'d'
  end

  describe '#aspect' do
    it 'should be spec\'d'
  end
end
