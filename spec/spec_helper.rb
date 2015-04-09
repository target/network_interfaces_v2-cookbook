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

# Require all our libraries
# require "#{File.join(File.dirname(__FILE__), '..', 'libraries')}/helpers.rb"
# require "#{File.join(File.dirname(__FILE__), '..', 'libraries')}/loader.rb"
# Dir["#{File.join(File.dirname(__FILE__), '..', 'libraries')}/resource_*.rb"].each { |f| require File.expand_path(f) }
# Dir["#{File.join(File.dirname(__FILE__), '..', 'libraries')}/provider_*.rb"].each { |f| require File.expand_path(f) }

at_exit { ChefSpec::Coverage.report! } unless Object.const_defined?('Guard')
