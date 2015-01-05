require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesAutoscalingGroup < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_autoscaling_group

  actions :create, :delete, :update
  default_action :create

  attribute :id, :name_attribute => true
  attribute :arn
  attribute :availability_zones
  attribute :created_at
  attribute :default_cooldown
  attribute :desired_capacity
  attribute :enabled_metrics, :default => []
  attribute :health_check_grace_period
  attribute :health_check_type, :default => 'EC2'
  attribute :instances
  attribute :launch_configuration
  attribute :load_balancer_names, :default => []
  attribute :max_size
  attribute :min_size
  attribute :placement_group
  attribute :suspended_processes, :default => []
  attribute :tags
  attribute :termination_policies, :default => ['Default']
  attribute :vpc_zone_identifier

  attribute :aws_access_key_id, :default => nil
  attribute :aws_secret_access_key, :default => nil
  attribute :region, :default => 'us-east-1'

  attr_accessor :launch_configuration_name
  attr_accessor :servers
end
