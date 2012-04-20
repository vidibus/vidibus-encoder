require 'vidibus/encoder/helper'
require 'vidibus/encoder/util'
require 'vidibus/encoder/base'

module Vidibus
  module Encoder
    extend self

    class Error < StandardError; end
    class ProcessingError < Error; end
    class DataError < Error; end
    class ConfigurationError < Error; end
    class InputError < ConfigurationError; end
    class OutputError < ConfigurationError; end
    class ProfileError < ConfigurationError; end
    class RecipeError < ConfigurationError; end
    class FlagError < ConfigurationError; end

    attr_accessor :formats
    @formats = {}

    # Register a new encoder format.
    def register_format(name, processor)
      unless processor.new.is_a?(Vidibus::Encoder::Base)
        raise(ArgumentError, 'The processor must inherit Vidibus::Encoder::Base')
      end
      @formats ||= {}
      @formats[name] = processor
    end

    # Return the custom or standard logger.
    # If Rails is around, Rails.logger will be used
    # by default.
    def logger
      @logger ||= begin
        defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      end
    end

    # Set a custom logger instance.
    def logger=(instance)
      @logger = instance
    end
  end
end
