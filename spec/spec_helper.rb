require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'chefspec'

require 'chef/platform'
require 'chef/run_context'
require 'chef/resource'
require 'chef/resource/service'
require 'chef/provider/service/simple'
require 'chef/event_dispatch/base'
require 'chef/event_dispatch/dispatcher'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'libraries'))

require 'shared_stuff'

require 'mixin_delete'

require 'service_auto_scaling'
require 'service_compute'
require 'service_dns'
require 'service_elb'

require 'provider_base'

%w(autoscaling_group dns_zone dns_record dhcp_options launch_configuration load_balancer security_group server subnet vpc).each do |thing|
  require "resource_#{thing}"
  require "provider_#{thing}"
end

# RSpec.configure do |config|
#   config.color_enabled = true
# end
