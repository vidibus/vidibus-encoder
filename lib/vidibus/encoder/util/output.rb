module Vidibus
  module Encoder
    module Util
      class Output

        attr_accessor :path
        attr_reader :base

        # Initialize an output object.
        # Two options are required:
        #
        # :base [Vidibus::Encoder::Base] The encoder object
        # :path [String]  The path to the output file or directory
        def initialize(options)
          @base = options[:base]
          @path = options[:path]
          make_dir
        end

        # Return the output path.
        def to_s
          file_path || path
        end

        # Return the directory name from path.
        def dir
          @dir ||= directory? ? path : File.dirname(path)
        end

        # Extract the file name from given path or input file.
        def file_name
          path[/([^\/]+\.[^\/]+)$/, 1] || begin
            if base.input
              base_name(base.input.path).tap do |name|
                if base.profile
                  name << ".#{base.profile.file_extension}"
                  if base.profile.name && base.profile.name.to_s != 'default'
                    name.gsub!(/(\.[^\.]+)$/, "-#{base.profile.name}\\1")
                  end
                else
                  raise(OutputError, 'Could not determine file name because the current profile does not define a file extension')
                end
              end
            else
              raise(OutputError, 'Could not determine file name from input or output path')
            end
          end
        end

        def file_path
          File.join(dir, file_name) if file_name
        end

        def base_name(str = file_name)
          str[/([^\/]+)\.[^\.]+$/, 1]
        end

        # Return true if a path has been defined.
        def present?
          !!path
        end

        # Return true if path exists
        def exist?
          File.exist?(path)
        end

        # Return true if path is a directory
        def directory?
          File.directory?(path)
        end

        # Ensure that a path is given.
        def validate
          present? || raise(OutputError, 'No output defined')
        end

        # Create output directory
        def make_dir
          FileUtils.mkdir_p(dir) unless exist?
        end

        # Copy files from tmp folder to output folder.
        def copy_files
          begin
            files = Dir.glob("#{base.tmp}/*")
            FileUtils.cp_r(files, dir)
            files.each do |file|
              file.gsub!(base.tmp.to_s, dir)
            end
          rescue => e
            raise("Copying output files from #{base.tmp} to #{path} failed: #{e.message}")
          end
        end
      end
    end
  end
end
