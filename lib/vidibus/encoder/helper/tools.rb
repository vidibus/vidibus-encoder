module Vidibus
  module Encoder
    module Helper
      module Tools

        # Return a matching frame rate from given list.
        # You may use this method to determine which of your valid frame rates
        # fits the input best.
        def matching_frame_rate(list)
          raise(ArgumentError, 'Argument must be an array') unless list && list.is_a?(Array)
          input_frame_rate = input.frame_rate
          list.each do |rate|
            return rate if rate == input_frame_rate
          end
          # Detect the smallest multiple of any list entry
          lowest_q = nil
          wanted = nil
          list.each do |rate|
            q, r = input_frame_rate.divmod(rate)
            if r == 0 && (!lowest_q || lowest_q > q)
              lowest_q = q
              wanted = rate
            end
          end
          wanted
        end
      end
    end
  end
end
