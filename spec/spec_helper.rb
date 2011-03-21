$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'glitr'

SpecRoot = Pathname.new File.expand_path('..', __FILE__)

RSpec.configure do |config|
  config.color_enabled = true
  config.mock_with :mocha

  config.formatter = :progress
  config.color_enabled = true
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :they
end
