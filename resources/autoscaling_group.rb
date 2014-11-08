
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesAutoscalingGroup
end

actions :create, :delete, :update
default_action :create

attribute :id, :name_attribute => true
attribute :arn
attribute :availability_zones
attribute :created_at
attribute :default_cooldown
attribute :desired_capacity
attribute :enabled_metrics
attribute :health_check_grace_period
attribute :health_check_type
attribute :instances
attribute :launch_configuration_name
attribute :load_balancer_names
attribute :max_size
attribute :min_size
attribute :placement_group
attribute :suspended_processes
attribute :tags
attribute :termination_policies
attribute :vpc_zone_identifier

attribute :aws_access_key_id, :default => nil
attribute :aws_secret_access_key, :default => nil
