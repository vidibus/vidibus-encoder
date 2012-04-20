require 'spec_helper'

describe Vidibus::Encoder::Util::Profile do
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

  def stub_input
    stub(profile.base).input { input }
  end

  describe 'initializing' do
    it 'should work without arguments' do
      expect { Vidibus::Encoder::Util::Profile.new }.not_to raise_error
    end

    it 'should work with valid attributes' do
      expect { profile }.not_to raise_error
    end
  end

  describe 'method_missing' do
    it 'should catch any settings entry' do
      profile.settings = {:what => 'ever'}
      profile.what.should eq('ever')
    end

    it 'should return nil for non-existing settings' do
      profile.whatthefuck.should be_nil
    end
  end

  describe '#attributes' do
    it 'should return all settings including :width, :height, and :dimensions' do
      profile.attributes.should eq([
        'audio_bit_rate',
        'audio_channels',
        'audio_samplerate',
        'dimensions',
        'frame_rate',
        'height',
        'video_bit_rate',
        'width'
      ])
    end
  end

  describe '#validate' do
    it 'should require a :name' do
      profile.name = nil
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a name for this profile')
    end

    it 'should fail if :name is blank' do
      profile.name = ''
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a name for this profile')
    end

    it 'should require :settings' do
      profile.settings = nil
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a settings hash for this profile')
    end

    it 'should fail if :settings is not a Hash' do
      profile.settings = 'something'
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a settings hash for this profile')
    end

    it 'should fail if :settings are empty' do
      profile.settings = {}
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a settings hash for this profile')
    end

    it 'should fail without a base' do
      profile.base = nil
      expect { profile.validate }.to raise_error(Vidibus::Encoder::ProfileError, 'Define a encoder class for this profile')
    end

    it 'should work with valid attributes' do
      expect { profile.validate }.not_to raise_error
    end
  end

  describe '#bit_rate' do
    it 'should return the bit_rate' do
      stub(profile).settings do
        {:bit_rate => 999 }
      end
      profile.bit_rate.should eq(999)
    end

    it 'should calculate bit_rate from audio and video bit_rate' do
      profile.bit_rate.should eq(142000)
    end

    it 'should calculate bit_rate even if audio bit_rate is nil' do
      stub(profile).audio_bit_rate {}
      profile.bit_rate.should eq(110000)
    end

    it 'should calculate bit_rate even if video bit_rate is nil' do
      stub(profile).video_bit_rate {}
      profile.bit_rate.should eq(32000)
    end
  end

  describe '#width' do
    before do
      stub_input
    end

    context 'without arguments' do
      it 'should return the wanted width' do
        profile.settings[:width] = 250
        profile.width.should eq(250)
      end

      it 'should return the width from dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.width.should eq(200)
      end

      it 'should return the input width if no settings are available' do
        profile.width.should eq(720)
      end

      it 'should calculate the width from input if height is defined' do
        profile.settings[:height] = 100
        profile.width.should eq(150)
      end

      it 'should scale down wanted width' do
        profile.settings[:width] = 1280
        profile.width.should eq(720)
      end

      it 'should scale down wanted width if wanted height is too large' do
        profile.settings[:width] = 290
        profile.settings[:height] = 1000
        profile.width.should eq(139)
      end

      it 'should limit width if wanted height is too large' do
        profile.settings[:height] = 1000
        profile.width.should eq(720)
      end
    end

    context 'with modulus 16' do
      it 'should adjust the wanted width' do
        profile.settings[:width] = 250
        profile.width(16).should eq(240)
      end

      it 'should derive the width from dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.width(16).should eq(192)
      end

      it 'should adjust the input width if no settings are available' do
        stub(input).width { 710 }
        profile.width(16).should eq(704)
      end

      it 'should calculate the width from input if height is defined' do
        profile.settings[:height] = 100
        profile.width(16).should eq(144)
      end

      it 'should scale down wanted width' do
        profile.settings[:width] = 1280
        profile.width(16).should eq(720)
      end

      it 'should scale down width if wanted height is too large' do
        profile.settings[:width] = 290
        profile.settings[:height] = 1000
        profile.width(16).should eq(128)
      end

      it 'should limit width if wanted height is too large' do
        profile.settings[:height] = 1000
        profile.width(16).should eq(720)
      end
    end
  end

  describe '#height' do
    before do
      stub_input
    end

    context 'without arguments' do
      it 'should return the wanted height' do
        profile.settings[:height] = 170
        profile.height.should eq(170)
      end

      it 'should return the height from dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.height.should eq(150)
      end

      it 'should return the input height if no settings are available' do
        profile.height.should eq(480)
      end

      it 'should calculate the height from input if width is defined' do
        profile.settings[:width] = 240
        profile.height.should eq(160)
      end

      it 'should scale down wanted height' do
        profile.settings[:height] = 900
        profile.height.should eq(480)
      end

      it 'should scale down height if wanted width is too large' do
        profile.settings[:width] = 1100
        profile.settings[:height] = 290
        profile.height.should eq(190)
      end

      it 'should limit height if wanted width is too large' do
        profile.settings[:width] = 1100
        profile.height.should eq(480)
      end
    end

    context 'with modulus 16' do
      it 'should adjust the wanted height' do
        profile.settings[:height] = 170
        profile.height(16).should eq(160)
      end

      it 'should derive the height from dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.height(16).should eq(144)
      end

      it 'should adjust the input height if no settings are available' do
        stub(input).height { 450 }
        profile.height(16).should eq(448)
      end

      it 'should calculate the height from input if width is defined' do
        profile.settings[:width] = 300
        profile.height(16).should eq(192)
      end

      it 'should scale down wanted height' do
        profile.settings[:height] = 900
        profile.height(16).should eq(480)
      end

      it 'should scale down height if wanted width is too large' do
        profile.settings[:width] = 1100
        profile.settings[:height] = 290
        profile.height(16).should eq(176)
      end

      it 'should limit height if wanted width is too large' do
        profile.settings[:width] = 1100
        profile.height(16).should eq(480)
      end
    end
  end

  describe '#dimensions' do
    before do
      stub_input
    end

    context 'without arguments' do
      it 'should return the wanted dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.dimensions.should eq('200x150')
      end

      it 'should take dimensions from input, if neither width nor height is provided' do
        profile.dimensions.should eq('720x480')
      end

      it 'should calculate dimensions from wanted width' do
        profile.settings[:width] = 308
        profile.dimensions.should eq('308x205')
      end

      it 'should calculate dimensions from wanted height' do
        profile.settings[:height] = 200
        profile.dimensions.should eq('300x200')
      end

      it 'should scale down the wanted dimensions' do
        profile.settings[:dimensions] = '1000x300'
        profile.dimensions.should eq('720x216')
      end

      it 'should scale down the wanted width' do
        profile.settings[:width] = '1280'
        profile.dimensions.should eq('720x480')
      end
    end

    context 'with modulus 16' do
      it 'should recalculate the wanted dimensions' do
        profile.settings[:dimensions] = '200x150'
        profile.dimensions(16).should eq('192x144')
      end

      it 'should derive dimensions from input, if neither width nor height is provided' do
        stub(input).width { 710 }
        stub(input).height { 430 }
        profile.dimensions(16).should eq('704x416')
      end

      it 'should calculate dimensions from width, if given' do
        profile.settings[:width] = 308
        profile.dimensions(16).should eq('304x192')
      end

      it 'should calculate dimensions from height, if given' do
        profile.settings[:height] = 200
        profile.dimensions(16).should eq('288x192')
      end

      it 'should scale down the wanted dimensions' do
        profile.settings[:dimensions] = '1000x300'
        profile.dimensions(16).should eq('720x208')
      end
    end
  end
end
