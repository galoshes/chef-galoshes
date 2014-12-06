require 'simplecov'
require 'codeclimate-test-reporter'

SimpleCov.add_filter 'vendor'
SimpleCov.formatters = Coveralls::SimpleCov::Formatter
SimpleCov.start CodeClimate::TestReporter.configuration.profile

require 'chefspec'

require 'chef/platform'
require 'chef/run_context'
require 'chef/resource'
require 'chef/resource/service'
require 'chef/provider/service/simple'
require 'chef/event_dispatch/base'
require 'chef/event_dispatch/dispatcher'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'libraries'))

require 'mixin_delete'
require 'provider_base'

require 'resource_dns_zone'
require 'provider_dns_zone'

# RSpec.configure do |config|
#   config.color_enabled = true
# end
