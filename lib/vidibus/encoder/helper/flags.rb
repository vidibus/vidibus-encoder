module Vidibus
  module Encoder
    module Helper
      module Flags

        # Register the inheritable reader +registered_flags+ on class level.
        def self.extended(base)
          base.class_eval <<-RUBY
            unless defined?(@@registered_flags)
              @@registered_flags = {}
            end

            def self.registered_flags
              @@registered_flags
            end
          RUBY
        end

        # Register a flag handler. A flag handler will be called when
        # rendering the encoding recipe if a matching profile setting is
        # available.
        #
        # Usage:
        #
        #   class MyEncoder < Vidibus::Encoder::Base
        #     flag(:active) { |value| "-v #{value}"}
        #   end
        def flag(name, &block)
          raise(ArgumentError, 'Block is missing') unless block_given?
          registered_flags[name.to_sym] = block
        end
      end
    end
  end
end
