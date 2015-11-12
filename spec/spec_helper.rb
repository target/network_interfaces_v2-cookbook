require 'chefspec'
require 'chefspec/berkshelf'

require_relative 'support/matchers'

RSpec.configure do |config|
  config.log_level = :error

  config.color = true
  config.formatter = :documentation
end

# Add libraries to our LOAD_PATH
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'libraries'))

at_exit { ChefSpec::Coverage.report! } unless Object.const_defined?('Guard')
