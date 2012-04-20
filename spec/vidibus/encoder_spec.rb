require 'spec_helper'

class FakeEncoder; end
class MyEncoder < Vidibus::Encoder::Base; end

describe Vidibus::Encoder do
  describe '#register_format' do
    it 'should require a name' do
      expect { Vidibus::Encoder.register_format }.
        to raise_error(ArgumentError)
    end

    it 'should require a processor klass' do
      expect { Vidibus::Encoder.register_format(:my_format) }.
        to raise_error(ArgumentError)
    end

    it 'should raise an argument error if processor is of wrong type' do
      expect { Vidibus::Encoder.register_format(:my_format, FakeEncoder) }.
        to raise_error(ArgumentError, 'The processor must inherit Vidibus::Encoder::Base')
    end

    context 'with proper arguments' do
      before do
        @args = [:my_format, MyEncoder]
      end

      it 'should not throw an error' do
        expect { Vidibus::Encoder.register_format(*@args) }.
          not_to raise_error
      end

      it 'should register the format' do
        Vidibus::Encoder.register_format(*@args)
        Vidibus::Encoder.formats.should eq({:my_format => MyEncoder})
      end
    end
  end

  describe '#logger' do
    before do
      Vidibus::Encoder.instance_variable_set('@logger', nil)
      @logger = OpenStruct.new
    end

    it 'should return a new STDOUT logger by default' do
      stub(Logger).new(STDOUT) { @logger }
      Vidibus::Encoder.logger.should eq(@logger)
    end

    it 'should return Rails.logger if Rails is around' do
      Rails = OpenStruct.new
      stub(Rails).logger { @logger }
      Vidibus::Encoder.logger.should eq(@logger)
    end

    it 'should return a custom logger, if defined' do
      Vidibus::Encoder.instance_variable_set('@logger', @logger)
      Vidibus::Encoder.logger.should eq(@logger)
    end
  end

  describe '#logger=' do
    it 'should set a custom logger' do
      Vidibus::Encoder.logger = 'whatever'
      Vidibus::Encoder.instance_variable_get('@logger').should eq('whatever')
    end
  end
end
