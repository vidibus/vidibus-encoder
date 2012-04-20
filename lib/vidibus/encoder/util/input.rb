module Vidibus
  module Encoder
    module Util
      class Input

        attr_accessor :path
        attr_reader :properties

        # Initialize an input object.
        # One option is required:
        #
        # :path [String]  The path to the input file
        def initialize(options)
          @path = options[:path]
          set_properties!
        end

        # Return the path.
        def to_s
          path
        end

        # Return true if path is readable.
        def readable?
          File.readable?(path)
        end

        # Ensure that a path is given and readable.
        def validate
          readable? || raise(InputError, 'Input is not readable')
        end

        # Return aspect ratio of input file.
        def aspect
          @aspect ||= width/height.to_f
        end

        private

        # Analyze file info of input and set properties.
        # If analysis fails, a DataError will be raised.
        def set_properties!
          return unless present?
          begin
            @properties = Fileinfo(path)
          rescue => error
          end
          @properties || raise(DataError, "Extracting input data failed!\n#{error}\n")
        end

        # Try to return value from properties hash. Return nil if property is
        # undefined or nil.
        def method_missing(sym, *arguments)
          if properties && value = properties[sym]
            value
          else
            nil
          end
        end
      end
    end
  end
end
