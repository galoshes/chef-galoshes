require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesLoadBalancer < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_load_balancer

  actions :create
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :region, :kind_of => [String, NilClass]
  attribute :availability_zones, :kind_of => [Array, NilClass], :default => []
  attribute :health_check, :kind_of => [Hash, NilClass]
  attribute :security_groups, :kind_of => [Array, NilClass]
  attribute :scheme, :kind_of => [String, NilClass], :equal_to => ['internal', 'internet-facing']
  attribute :listeners, :kind_of => [Array, NilClass]

  attribute :subnets, :kind_of => [Array, NilClass], :default => nil
end
