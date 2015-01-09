require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesLoadBalancer < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_load_balancer

  actions :create, :delete
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :id
  attribute :region, :kind_of => [String, NilClass]
  attribute :availability_zones, :kind_of => [Array, NilClass], :default => []
  attribute :health_check, :kind_of => [Hash, NilClass]
  attribute :security_groups, :kind_of => [Array, NilClass]
  attribute :scheme, :kind_of => [String, NilClass], :equal_to => ['internal', 'internet-facing']
  attribute :listeners, :kind_of => [Array, NilClass]

  attribute :subnet_ids, :kind_of => [Array, NilClass], :default => nil

  attribute :aws_access_key_id, :default => nil
  attribute :aws_secret_access_key, :default => nil
  attribute :region, :default => 'us-east-1'

  attribute :dns_name
  attribute :created_at
  attribute :instances
end
