module Vidibus
  module Encoder
    module Util
      class Flags
        include Enumerable

        attr_accessor :base

        # Initialize a flags object.
        # One option is required to pass validation:
        #
        # :base [Vidibus::Encoder::Base] The encoder object
        def initialize(options = {})
          @base = options[:base]
        end

        # Ensure that the base attribute is around.
        def validate
          raise(FlagError, 'Define a base class for flags') unless base
        end

        # This method turns the recipe into a command string by replacing all
        # placeholders and removing empty ones.
        #
        # If a flag handler is defined for a placeholder and the profile
        # setting is present, the flag handler will be called.
        #
        # Examples:
        #
        #   base = Vidibus::Encoder::Base.new
        #   flags = Vidibus::Encoder::Util::Flags.new(:base => base)
        #   profile = Vidibus::Encoder::Util::Profile.new(:base => base)
        #   encoder.instance_variable_set('@profile', profile)
        #
        #   recipe = 'some %{thing}'
        #
        #   # Without a matching profile setting
        #   flags.render(recipe)
        #    # => 'some '
        #
        #   # With a matching profile setting
        #   encoder.profile.settings[:thing] = 'beer'
        #   flags.render(recipe)
        #   # => 'some beer'
        #
        #   # With a matching profile setting and flag handler
        #   encoder.profile.settings[:thing] = 'beer'
        #   encoder.class.flag(:thing) { |value| "cold #{value}" }
        #   flags.render(recipe)
        #   # => 'some cold beer'
        def render(recipe)
          recipe = recipe.gsub(/%\{([^\{]+)\}/) do |match|
            flag = $1.to_sym
            value = base.profile.try!(flag)
            if value
              if handler = base.class.registered_flags[flag]
                match = base.instance_exec(value, &handler)
              else
                match = value
              end
            end
            match
          end
          recipe = render_input(recipe)
          recipe = render_output(recipe)
          cleanup(recipe)
        end

        # Replace %{input} placeholder in recipe.
        def render_input(recipe)
          recipe % {:input => %("#{base.input}")}
        end

        # Replace %{output} placeholder in recipe.
        def render_output(recipe)
          return recipe unless base.input && base.output
          output = base.tmp.join(base.output.file_name)
          recipe % {:output => %("#{output}")}
        end

        # Remove empty placeholders.
        def cleanup(recipe)
          recipe.gsub(/%\{[^\{]+\}/, '').gsub(/ +/, ' ')
        end
      end
    end
  end
end
