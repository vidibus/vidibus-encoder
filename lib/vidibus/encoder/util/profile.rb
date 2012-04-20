module Vidibus
  module Encoder
    module Util
      class Profile
        attr_accessor :name, :settings, :base

        def initialize(options = {})
          @name = options[:name]
          @settings = options[:settings] || {}
          @base = options[:base]
        end

        # Sum up audio and video bit_rate unless bit_rate
        # has been defined in settings.
        def bit_rate
          settings[:bit_rate] || audio_bit_rate.to_i + video_bit_rate.to_i
        end

        # Ensure that all required attribtues have been set.
        def validate
          raise(ProfileError, 'Define a name for this profile') if [nil, ''].include?(name)
          raise(ProfileError, 'Define a settings hash for this profile') unless settings.is_a?(Hash) && settings.any?
          raise(ProfileError, 'Define an encoder class for this profile') unless base
        end

        # Return a list of all profile attributes
        # including the given settings.
        def attributes
          @attributes ||= (settings.keys.map(&:to_s) + %w[width height dimensions]).sort.uniq
        end

        # Return the width. If the wanted width exceeds the
        # input's one, it will be scaled down.
        #
        # Define a modulus attribute to adjust dimensions. For best
        # encoding results, the modulus should be 16. 8, 4, and
        # even 2 will also work, but image quality increases with
        # higher numbers because compression works better.
        #
        # @modulus  [Integer] The modulus for rounding the value
        #
        # @return [Integer] The width
        def width(modulus = 1)
          @width ||= {}
          @width[modulus] = dim(:width, modulus)
        end

        # Return the height. If the wanted height exceeds the
        # input's one, it will be scaled down.
        #
        # Define a modulus attribute to adjust dimensions. For best
        # encoding results, the modulus should be 16. 8, 4, and
        # even 2 will also work, but image quality increases with
        # higher numbers because compression works better.
        #
        # @modulus  [Integer] The modulus for rounding the value
        #
        # @return [Integer] The height
        def height(modulus = 1)
          @height ||= {}
          @height[modulus] = dim(:height, modulus)
        end

        # Return dimensions. If wanted dimensions exceed the input's
        # ones, they will be scaled down.
        #
        # Define a modulus attribute to adjust dimensions. For best
        # encoding results, the modulus should be 16. 8, 4, and
        # even 2 will also work, but image quality increases with
        # higher numbers because compression works better.
        #
        # @modulus  [Integer] The modulus for rounding the value
        #
        # @return [String] The dimensions
        def dimensions(modulus = 1)
          @dimensions ||= {}
          @dimensions[modulus] = begin
            "#{width(modulus)}x#{height(modulus)}"
          end
        end

        # Return the aspect ratio of width to height as string like "16:9".
        # Define a modulus attribute to adjust dimensions.
        #
        # @modulus  [Integer] The modulus for rounding the value
        #
        # @return [String] The dimensions
        def aspect_ratio(modulus = 1)
          @aspect_ratio ||= settings[:aspect_ratio] ||= begin
            w = width(modulus)
            h = height(modulus)
            if w > 0 && h > 0
              w/h.to_f
            else
              1
            end
          end
        end

        def file_extension
          @file_extension ||= settings[:file_extension] || base.class.file_extension || raise(ProfileError, 'Define a file extension for this profile')
        end

        private

        # Try to return value from settings hash. Return nil if setting is
        # undefined or nil.
        def method_missing(sym, *arguments)
          if settings && value = settings[sym]
            value
          # elseif TODO: check if it's a setter
          else
            nil
          end
        end

        # Return the wanted dimension. If it exceeds the input's
        # one, it will be scaled down.
        #
        # The dimension will be optained from one of
        # the following sources:
        #   1. from the value given in settings
        #   2. from dimensions given in settings
        #   3. calculated from opposite value, if given
        #   4. from the input's properties
        #
        # @wanted   [Symbol]  The wanted dimension: :width or :height
        # @modulus  [Integer] The modulus for rounding the value
        #
        # @return [Integer] The width
        def dim(wanted, modulus = 1)
          modulus = modulus.to_i

          w = (wanted == :width)
          value = settings[wanted]
          given = base.input.send(wanted).to_f

          opposite = w ? :height : :width
          _value = settings[opposite]
          _given = base.input.send(opposite).to_f

          if !value && settings[:dimensions]
            matches = settings[:dimensions].match(/(\d+)x(\d+)/).to_a
            i = w ? 1 : -1
            value = matches[i]
            _value ||= matches[-i]
          end

          if value
            value = value.to_i
            if value > given
              value = given
            end
            if _value && _value.to_i > _given
              value *= _given/_value.to_f
            end
          else
            value = given
            if _value && _value.to_i < _given
              value *= _value.to_f/_given
            end
          end

          if modulus > 1
            q, r = value.to_i.divmod(modulus)
            value = q * modulus
          end
          value.round
        end
      end
    end
  end
end
