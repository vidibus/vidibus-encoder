require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rr'
require 'vidibus-encoder'
require 'ostruct'

require 'support/stubs'

RSpec.configure do |config|
  config.mock_with :rr
end
