require 'spec_helper'

describe Vidibus::Encoder::Util::Output do
  let(:base) { Vidibus::Encoder::Base.new }
  let(:output) do
    Vidibus::Encoder::Util::Output.new(:path => 'what/ever', :base => base)
  end
  let(:input) do
    stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
    util = Vidibus::Encoder::Util::Input.new(:path => 'some/input.mp4', :base => base)
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
  let(:profile) do
    Vidibus::Encoder::Util::Profile.new(
      :name => 'default',
      :settings => {
        :file_extension => 'mp4'
      },
      :base => base
    )
  end

  describe 'initializing' do
    it 'should be spec\'d'
  end

  describe '#to_s' do
    it 'should be spec\'d'
  end

  describe '#dir' do
    it 'should be spec\'d'
  end

  describe '#file_name' do
    it 'should raise an error by default' do
      expect { output.file_name }.
        to raise_error(Vidibus::Encoder::OutputError, 'Could not determine file name from input or output path')
    end

    it 'should determine the file name from output path' do
      output.path = 'what/ever/it_takes.m3u8'
      output.file_name.should eq('it_takes.m3u8')
    end

    it 'does something' do
      # to raise_error(Vidibus::Encoder::OutputError, 'Could not determine file name because the current profile does not define a file extension')
    end

    context 'with input path and profile' do
      before do
        stub(base).input { input }
        stub(base).profile { profile }
      end

      it 'should determine the file name' do
        output.file_name.should eq('input.mp4')
      end

      it 'should append the profile name unless it\'s "default"' do
        stub(profile).name { 'whatever' }
        output.file_name.should eq('input-whatever.mp4')
      end
    end
  end

  describe '#present?' do
    it 'should be spec\'d'
  end

  describe '#validate' do
    it 'should be spec\'d'
  end

  describe '#make_dir' do
    it 'should be spec\'d'
  end

  describe '#copy_files' do
    it 'should be spec\'d'
  end
end
