require 'spec_helper'

describe Vidibus::Encoder::Base do
  let(:base) { Vidibus::Encoder::Base.new }

  describe 'initializing' do
    it 'should not require arguments' do
      expect { Vidibus::Encoder::Base.new }.not_to raise_error
    end

    it 'should set options from arguments' do
      base = Vidibus::Encoder::Base.new(:some => :option)
      base.options.should eq(:some => :option)
    end

    it 'should set profile from arguments' do
      mock.any_instance_of(Vidibus::Encoder::Base).profile=('profile')
      Vidibus::Encoder::Base.new(:profile => 'profile')
    end

    it 'should set profiles from arguments' do
      mock.any_instance_of(Vidibus::Encoder::Base).profiles=('profiles')
      Vidibus::Encoder::Base.new(:profiles => 'profiles')
    end

    it 'should set tmp from arguments' do
      mock.any_instance_of(Vidibus::Encoder::Base).tmp=('tmp')
      Vidibus::Encoder::Base.new(:tmp => 'tmp')
    end

    it 'should set input from arguments' do
      mock.any_instance_of(Vidibus::Encoder::Base).input=('input')
      Vidibus::Encoder::Base.new(:input => 'input')
    end

    it 'should set output from arguments' do
      mock.any_instance_of(Vidibus::Encoder::Base).output=('output')
      Vidibus::Encoder::Base.new(:output => 'output')
    end
  end

  describe '#profiles=' do
    context 'with any input' do
      it 'should initialize a profiles util' do
        mock(Vidibus::Encoder::Util::Profiles).new(:profiles => 'profiles', :base => base)
        base.profiles = 'profiles'
      end

      it 'should set the profiles attribute' do
        base.instance_variable_set('@profiles', 'whatever')
        base.profiles = 'profiles'
        base.profiles.should be_a(Vidibus::Encoder::Util::Profiles)
      end
    end

    context 'with nil input' do
      it 'should raise an argument error' do
        expect { base.profiles = nil }.to raise_error(ArgumentError, 'Nil is not allowed')
      end

      it 'should not override the profiles attribute' do
        base.instance_variable_set('@profiles', 'whatever')
        begin
          base.profiles = nil
        rescue ArgumentError
        end
        base.profiles.should eq('whatever')
      end
    end
  end

  describe '#profile=' do
    context 'with any input' do
      it 'should initialize a profiles util' do
        mock(Vidibus::Encoder::Util::Profiles).new(:profile => 'profile', :base => base)
        base.profile = 'profile'
      end

      it 'should set the profiles attribute' do
        base.instance_variable_set('@profiles', 'whatever')
        base.profile = 'profile'
        base.profiles.should be_a(Vidibus::Encoder::Util::Profiles)
      end
    end

    context 'with nil input' do
      it 'should raise an argument error' do
        expect { base.profile = nil }.to raise_error(ArgumentError, 'Nil is not allowed')
      end

      it 'should not override the profiles attribute' do
        base.instance_variable_set('@profiles', 'whatever')
        begin
          base.profile = nil
        rescue ArgumentError
        end
        base.profiles.should eq('whatever')
      end
    end
  end

  describe '#tmp=' do
    context 'with any input' do
      it 'should initialize a tmp util' do
        mock(Vidibus::Encoder::Util::Tmp).new(:path => 'tmp', :base => base)
        base.tmp = 'tmp'
      end

      it 'should set the tmp attribute' do
        base.instance_variable_set('@tmp', 'whatever')
        base.tmp = 'tmp'
        base.tmp.should be_a(Vidibus::Encoder::Util::Tmp)
      end
    end

    context 'with nil input' do
      it 'should raise an argument error' do
        expect { base.tmp = nil }.to raise_error(ArgumentError, 'Nil is not allowed')
      end

      it 'should not override the tmp attribute' do
        base.instance_variable_set('@tmp', 'whatever')
        begin
          base.tmp = nil
        rescue ArgumentError
        end
        base.tmp.should eq('whatever')
      end
    end
  end

  describe '#input=' do
    context 'with any input' do
      it 'should initialize an input util' do
        stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
        mock(Vidibus::Encoder::Util::Input).new(:path => 'input', :base => base)
        base.input = 'input'
      end

      it 'should set the input attribute' do
        stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
        base.instance_variable_set('@input', 'whatever')
        base.input = 'input'
        base.input.should be_a(Vidibus::Encoder::Util::Input)
      end
    end

    context 'with nil input' do
      it 'should raise an argument error' do
        expect { base.input = nil }.to raise_error(ArgumentError, 'Nil is not allowed')
      end

      it 'should not override the input attribute' do
        base.instance_variable_set('@input', 'whatever')
        begin
          base.input = nil
        rescue ArgumentError
        end
        base.input.should eq('whatever')
      end

      it 'should not call analyze input' do
        dont_allow.any_instance_of(Vidibus::Encoder::Util::Input).analyze
        begin
          base.input = nil
        rescue ArgumentError
        end
      end
    end
  end

  describe '#output=' do
    context 'with any input' do
      it 'should initialize an output util' do
        mock(Vidibus::Encoder::Util::Output).new(:path => 'output', :base => base)
        base.output = 'output'
      end

      it 'should set the output attribute' do
        base.instance_variable_set('@output', 'whatever')
        base.output = 'output'
        base.output.should be_a(Vidibus::Encoder::Util::Output)
      end
    end

    context 'with nil input' do
      it 'should raise an argument error' do
        expect { base.output = nil }.to raise_error(ArgumentError, 'Nil is not allowed')
      end

      it 'should not override the output attribute' do
        base.instance_variable_set('@output', 'whatever')
        begin
          base.output = nil
        rescue ArgumentError
        end
        base.output.should eq('whatever')
      end
    end
  end

  describe '#run' do
    let(:base) do
      Vidibus::Encoder::Base.new.tap do |encoder|
        stub(File).readable?.with_any_args { true }
        stub.any_instance_of(Vidibus::Encoder::Util::Input).set_properties!
        stub(encoder.class).profile_presets do
          {:default => {:is => 'high'}}
        end
        encoder.input = 'input.mp4'
        encoder.output = 'output.mp4'
      end
    end

    it 'should require input' do
      stub(base).input { nil }
      expect { base.run }.to raise_error(Vidibus::Encoder::InputError, 'No input defined')
    end

    it 'should require readable input' do
      stub(File).readable?('input.mp4') { false }
      expect { base.run }.to raise_error(Vidibus::Encoder::InputError, 'Input is not readable')
    end

    it 'should require output' do
      stub(base).output { nil }
      expect { base.run }.to raise_error(Vidibus::Encoder::OutputError, 'No output defined')
    end

    it 'should require a default profile' do
      stub(base.class).profile_presets {}
      expect { base.run }.to raise_error(Vidibus::Encoder::ProfileError, 'No default profile defined')
    end

    it 'should require a valid single profile' do
      base.profile = :low
      expect { base.run }.to raise_error(Vidibus::Encoder::ProfileError, 'Profile :low is undefined')
    end

    it 'should require a valid multi profile' do
      base.profiles = [:low]
      expect { base.run }.to raise_error(Vidibus::Encoder::ProfileError, 'Profile :low is undefined')
    end

    context 'with a valid profile' do
      before do
        stub(base.class).profile_presets do
          {
            :default => {:this => {:is => 'high'}},
            :low => {:this => {:is => 'low'}}
          }
        end
      end

      it 'should check if profile may be processed' do
        mock(base).process?
        base.run
      end

      it 'should call #preprocess' do
        stub(base).process? { true }
        mock(base).preprocess
        expect { base.run }.to raise_error(Vidibus::Encoder::Error)
      end

      it 'should accept a single profile' do
        base.profile = :low
        expect { base.run }.not_to raise_error(Vidibus::Encoder::ProfileError, 'Profile :low is undefined')
      end

      it 'should accept a multi profile' do
        base.profiles = [:low]
        expect { base.run }.not_to raise_error(Vidibus::Encoder::ProfileError, 'Profile :low is undefined')
      end

      it 'should require a recipe' do
        expect { base.run }.to raise_error(Vidibus::Encoder::RecipeError, 'Please define an encoding recipe inside your encoder class')
      end

      context 'and a working recipe' do
        before do
          stub(base).recipe { 'echo "hello"' }
        end

        it 'should not raise an error' do
          expect { base.run }.not_to raise_error
        end

        it 'should call #handle_response with STDOUT and STDERR' do
          pending 'Learn how to stub Process'
          stub(POSIX::Spawn)::popen4 { [123, 'stdin', 'stdout', 'stderr'] }
          stub(Process)::wait2(123) { [456, OpenStruct.new]}
          mock(base).handle_response('stdout', 'stderr')
          base.run
        end

        it 'should call #postprocess' do
          mock(base).postprocess
          base.run
        end
      end

      context 'and a erroneous recipe' do
        before do
          stub(base).recipe { 'ffmpeg' }
        end

        it 'should raise an processing error' do
          expect { base.run }.to raise_error(Vidibus::Encoder::ProcessingError, /Execution failed:/)
        end

        it 'should not call #postprocess' do
          begin
            dont_allow(base).postprocess
            base.run
          rescue Vidibus::Encoder::ProcessingError
          end
        end
      end
    end
  end

  describe '.register_profile' do
    it 'should be tested'
  end
end
