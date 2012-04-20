require 'spec_helper'

describe Vidibus::Encoder::Util::Flags do
  let(:base) { Vidibus::Encoder::Base.new }

  let(:flags) do
    Vidibus::Encoder::Util::Flags.new(
      :base => base
    )
  end

  let(:profile) do
    util = Vidibus::Encoder::Util::Profile.new(:base => base)
    stub(util).settings do
      {
        :width => 720,
        :height => 480,
        :size => 300000,
        :duration => 5.3,
        :file_extension => 'flv'
      }
    end
    util
  end

  let(:input) do
    stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
    util = Vidibus::Encoder::Util::Input.new(:path => 'whatever.wmv', :base => base)
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

  let(:output) do
    Vidibus::Encoder::Util::Output.new(:path => 'what/ever', :base => base)
  end

  def stub_profile
    stub(flags.base).profile { profile }
  end

  def stub_input
    stub(flags.base).input { input }
  end

  def stub_output
    stub(flags.base).output { output }
  end

  describe '#render' do
    before do
      stub_profile
      stub_input
      stub_output
    end

    it 'should require an argument' do
      expect { flags.render }.to raise_error(ArgumentError)
    end

    it 'should replace empty placeholders' do
      flags.render('transcode %{some}').should eq('transcode ')
    end

    it 'should replace input placeholder with input path' do
      flags.render('transcode %{input}').should eq('transcode "whatever.wmv"')
    end

    it 'should replace output placeholder with output file path' do
      flags.render('transcode %{output}').should eq(%(transcode "/tmp/vidibus-encoder/#{base.uuid}/whatever.flv"))
    end

    it 'should replace settings placeholders' do
      flags.render('transcode -s %{width}x%{height}').should eq('transcode -s 720x480')
    end

    it 'should replace placeholders with flags' do
      stub(flags.base.class).registered_flags do
        {:dimensions => lambda { |value| "-s #{value}" }}
      end
      flags.render('transcode %{dimensions}').should eq('transcode -s 720x480')
    end

    it 'should allow access to instance variables in flag handlers' do
      flags.base.class.class_eval <<-RUBY
        flag(:size) do
          profile.size
        end
      RUBY
      flags.render('transcode %{size}').should eq('transcode 300000')
    end
  end
end
