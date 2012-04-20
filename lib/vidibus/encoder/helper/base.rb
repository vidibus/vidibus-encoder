module Vidibus
  module Encoder
    module Helper

      # This helper provides methods for the encoder base class.
      module Base

        # Define setters for profile options.
        # For either option, :profile or :profiles, a Util::Profiles object
        # will be initialized.
        [:profile, :profiles].each do |option|
          class_eval <<-EOT
            def #{option}=(settings)
              raise(ArgumentError, "Nil is not allowed") unless settings
              @profiles = Util::Profiles.new(
                #{option.inspect} => settings, :base => self
              )
            end
          EOT
        end

        # Define setters for other options.
        # For each option a Util:: Object will be initialized, which are
        # Util::Tmp, Util::Input, and Util::Output.
        [:tmp, :input, :output].each do |option|
          class_eval <<-EOT
            def #{option}=(input)
              raise(ArgumentError, "Nil is not allowed") unless input
              util = Util::#{option.to_s.classify}
              @#{option} = input.is_a?(util) ? input : util.new(:path => input, :base => self )
            end
          EOT
        end

        # TODO: DESCRIBE
        def uuid
          @uuid ||= Vidibus::Uuid.generate
        end

        # Reader for the logger.
        def logger
          Vidibus::Encoder.logger
        end
      end
    end
  end
end
