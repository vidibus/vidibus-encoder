require 'spec_helper'

describe Vidibus::Encoder::Util::Profiles do
  let(:profile) do
    Vidibus::Encoder::Util::Profile.new(
      :name => 'some',
      :settings => {
        :video_bit_rate => 110000,
        :audio_bit_rate => 32000,
        :audio_samplerate => 32000,
        :audio_channels => 1,
        :frame_rate => 8
      },
      :base => Vidibus::Encoder::Base.new
    )
  end

  let(:input) do
    stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
    util = Vidibus::Encoder::Util::Input.new(:path => 'whatever', :base => profile.base)
    stub(util).properties do
      {
        :width => 720,
        :height => 480,
        :size => 300000,
        :duration => 5.3
      }
    end
    util
  end

  describe 'initializing' do
    it 'should be spec\'d'
  end

  describe '#available' do
    it 'should be spec\'d'
  end

  describe '#collection' do
    it 'should be spec\'d'
  end

  describe '#each' do
    it 'should be spec\'d'
  end

  describe '#sorted' do
    it 'should be spec\'d'
  end

  describe '#validate' do
    it 'should be spec\'d'
  end
end
