module Vidibus
  module Encoder

    # This is the main encoder that you can build your own encoders on.
    #
    # The workflow of an encoder is as follows:
    #
    # initialize
    # run
    #   validate_options
    #   prepare
    #   => for each profile:
    #     next unless process?
    #     preprocess
    #     process
    #     postprocess
    #   finish
    #
    # Each step of the workflow is represented by a method that you may
    # redefine in your custom encoder class.
    class Base
      extend Helper::Flags
      include Helper::Base
      include Helper::Tools

      attr_reader :options, :tmp, :input, :output, :profile, :profiles

      # Initialize an encoder instance with given options. Two options are
      # mandatory:
      #
      # :input  [String]  The path to the input file
      # :output [String]  The path to the output file or directory
      #
      # You may define one or several profiles to perform. If you provide a
      # hash, all profile settings required for your recipe must be included.
      #
      # :profile  [Hash]  The configuration hash of one profile
      # :profiles [Hash]  Hashes of several profiles with namespace
      #
      # Single profile example:
      #
      #   :profile => {
      #     :video_bit_rate => 110000,
      #     :dimensions => '240x160'
      #   }
      #
      # Multi-profile example:
      #
      #   :profiles => {
      #     :low => {
      #       :video_bit_rate => 110000,
      #       :dimensions => '240x160'
      #     },
      #     :high => {
      #       :video_bit_rate => 800000,
      #       :dimensions => '600x400'
      #     }
      #   }
      #
      # If you have registered profiles for your encoder, you may refer to
      # one or several profiles by providing its name. Without a profile, the
      # default one will be performed.
      # To register a profile, call YourEncoder.register_profile
      #
      # :profile  [Symbol]  The name of one profile
      # :profiles [Array]   A list of profile names
      #
      # @options [Hash] The configuration options
      def initialize(options = {})
        @options = options
        [:tmp, :input, :output, :profile, :profiles].each do |attribute|
          self.send("#{attribute}=", options[attribute]) if options[attribute]
        end
        set_default_options
      end

      # Perform the encoding workflow.
      # All profiles will be performed in order. Lowest bit_rate first.
      def run
        validate_options
        prepare
        profiles.sorted.each do |@profile|
          next unless process?
          preprocess
          process
          postprocess
        end
        finish
      end

      # Fixed profile presets for this encoder.
      # You may define profile presets inside your encoder class.
      #
      # When defining settings, you should define a :default setting as well
      # to support single profile encodings.
      # An example:
      #
      #   {
      #     :low => {
      #       :video_bit_rate => 110000,
      #       :dimensions => '240x160'
      #     },
      #     :high => {
      #       :video_bit_rate => 800000,
      #       :dimensions => '600x400'
      #     }
      #   }.tap do |p|
      #     p[:default] = p[:high]
      #   end
      def self.profile_presets; end

      # Define a default file extension for your encoder.
      # Or define one in a profile configuration.
      def self.file_extension; end

      class << self
        attr_accessor :registered_profiles
        @registered_profiles = {}

        # Register a profile with given name and settings.
        def register_profile(name, settings)
          @registered_profiles[name] = settings
        end
      end

      private

      attr_reader :flags

      # This method holds the recipe to perform.
      # It is required that you define a custom encoding recipe inside your
      # encoder class.
      #
      # The recipe must be a executable string that may contain placeholders
      # that we call 'flags'. A simplified example:
      #
      #   'ffmpeg -i %{input} -threads 0 -y %{output}'
      #
      def recipe
        raise(RecipeError, 'Please define an encoding recipe inside your encoder class')
      end

      # Handle the response returned from processing.
      # Define a response handler for your recipe inside your encoder class.
      #
      # TODO: Example
      def handle_response(stdout, stderr); end

      # Set some default options.
      def set_default_options
        @profiles ||= Util::Profiles.new(:base => self)
        @tmp ||= Util::Tmp.new(:base => self)
        @flags ||= Util::Flags.new(:base => self)
      end

      # Ensure that valid options are given.
      # Please override this method if you need checks for custom arguments.
      #
      # By default, input, output, and profiles will be checked.
      def validate_options
        input ? input.validate : raise(InputError, 'No input defined')
        output ? output.validate : raise(OutputError, 'No output defined')
        profiles ? profiles.validate : raise(ProfileError, 'No profiles defined')
        flags ? flags.validate : raise(FlagError, 'No flags defined')
      end

      # Prepare for encoding.
      # Please override this method inside your encoder
      # class, if you need custom preparation.
      #
      # Currently, the tmp folder will be created.
      def prepare
        tmp.make_dir
      end

      # Decide whether the current profile should be processed.
      def process?
        true
      end

      # Preprocess each encoding profile.
      # Downsize video bit rate if it exceeds input bit rate.
      def preprocess
        if higher_bit_rate?
          profile.settings[:video_bit_rate] = input.bit_rate
        end
      end

      # Return true if wanted bit rate is higher than input's one.
      # Allow 5% tolerance.
      def higher_bit_rate?
        input.bit_rate && profile.bit_rate * 1.05 > input.bit_rate
      end

      # Perform the encoding command.
      # TODO: Describe.
      def process
        cmd = flags.render(recipe)
        logger.info("\nEncoding profile #{profile.name}...\n#{cmd}\n")
        pid, stdin, stdout, stderr = POSIX::Spawn::popen4(cmd)
        handle_response(stdout, stderr)
        ppid, status = Process::wait2(pid)
        unless status.exitstatus == 0
          raise(ProcessingError, "Execution failed:\n#{stderr.read}")
        end
      ensure # close all streams
        [stdin, stdout, stderr].each { |io| io.close rescue nil }
      end

      # Postprocess each encoding profile.
      def postprocess; end

      # Hook for finishing touches.
      # TODO: Describe.
      def finish
        encoded_files = output.copy_files
        tmp.remove_dir
        encoded_files
      end
    end
  end
end
