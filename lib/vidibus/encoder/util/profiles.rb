module Vidibus
  module Encoder
    module Util
      class Profiles
        include Enumerable

        attr_reader :profile, :profiles, :base

        def initialize(options)
          @base = options[:base]
          @profile = options[:profile]
          @profiles = options[:profiles]
        end

        # Return all profiles available for encoder base.
        # For better encapsulation this method is placed here.
        def available
          @available ||= begin
            (base.class.registered_profiles || {}).tap do |items|
              items.merge!(base.class.profile_presets) if base.class.profile_presets
            end
          end
        end

        # Return the used profile(s). If no profile is used, an empty hash
        # will be returned.
        #
        # @return [Hash] A collection of profile objects
        def collection
          @collection ||= begin
            begin
              map
            rescue ProfileError
              {}
            end
          end
        end
        alias :to_h :collection

        # Iterate over the used profiles.
        def each
          collection.each do |profile|
            yield(profile)
          end
        end

        # Return the used profiles, sorted by given attribute.
        #
        # attribute [Hash] A collection of profile objects
        #
        # Default sorting attribute is :bit_rate.
        def sorted(attribute = :bit_rate)
          @sorted ||= {}
          @sorted[attribute] ||= sort_by { |p| p.send(attribute) }
        end

        # Return true if profile config is available, raise a ProfileError
        # otherwise.
        def validate
          !!map || raise(ProfileError, 'No profiles defined')
        end

        # Return true if several profiles are in use.
        def multi?
          @is_multi ||= used.count > 1
        end

        private

        # Return a collection of mapped profile objects.
        def map
          @map ||= config.map do |name, settings|
            Profile.new.tap do |profile|
              profile.name = name
              profile.settings = settings
              profile.base = base
              profile.validate
            end
          end
        end

        # Return a profile hash for any given profile.
        def config
          @config ||= multi_config || single_config
        end

        # Return a config hash for wanted profiles.
        def multi_config
          if profiles.is_a?(Hash)
            profiles
          elsif profiles.is_a?(Array)
            {}.tap do |p|
              for name in profiles
                p[name] = available[name] ||
                  raise(ProfileError, "Profile #{name.inspect} is undefined")
              end
            end
          end
        end

        # Return a config hash for wanted profile.
        def single_config
          default = begin
            if profile.is_a?(Hash)
              profile
            elsif [String, Symbol].include?(profile.class)
              available[profile] ||
                raise(ProfileError, "Profile #{profile.inspect} is undefined")
            else
              available[:default] ||
                raise(ProfileError, 'No default profile defined')
            end
          end
          {:default => default}
        end
      end
    end
  end
end
