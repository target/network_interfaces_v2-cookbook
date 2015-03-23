require 'chefspec'
require 'chefspec/berkshelf'

require_relative 'support/matchers'

RSpec.configure do |config|
  config.log_level = :error
end

at_exit { ChefSpec::Coverage.report! }
