require 'spec_helper'

describe Vidibus::Encoder::Util::Tmp do
  describe 'DEFAULT' do
    it 'should return de default tmp path' do
      Vidibus::Encoder::Util::Tmp::DEFAULT.should eq('/tmp/vidibus-encoder')
    end
  end

  describe 'initializing' do
    it 'should be spec\'d'
  end

  describe '#to_s' do
    it 'should be spec\'d'
  end

  describe '#join' do
    it 'should be spec\'d'
  end

  describe '#make_dir' do
    it 'should be spec\'d'
  end

  describe '#remove_dir' do
    it 'should be spec\'d'
  end
end
