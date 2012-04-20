module Vidibus
  module Encoder
    module Util
      class Tmp
        DEFAULT = '/tmp/vidibus-encoder'

        attr_reader :path, :base

        # Initialize a tmp folder object.
        # One option is required:
        #
        # :base [Vidibus::Encoder::Base] The encoder object
        #
        # One option is optional:
        #
        # :path [String]  The path to the tmp folder
        def initialize(options)
          @base = options[:base]
          @path = File.join(options[:path] || DEFAULT, base.uuid)
        end

        # Return the default path.
        def to_s
          path
        end

        # Return a path with additional arguments.
        def join(*args)
          File.join(path, *args)
        end

        # Make a temporary folder.
        def make_dir
          FileUtils.mkdir_p(path)
        end

        # Remove the temporary folder.
        def remove_dir
          FileUtils.remove_dir(path) if File.exist?(path) && path.length > 3
        end
      end
    end
  end
end