require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesVpc < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_vpc
  actions :create
  default_action :create

  attribute :cidr_block, :kind_of => [String]
  attribute :id, :kind_of => [String], :default => nil
  attribute :dhcp_options_id, :kind_of => [String, NilClass], :default => nil
  attribute :tags, :kind_of => [Hash], :default => {}
  attribute :enable_dns_support, :kind_of => [TrueClass, FalseClass], :default => true
  attribute :enable_dns_hostnames, :kind_of => [TrueClass, FalseClass], :default => false
  attribute :tenancy, :equal_to => %w(default dedicated), :default => 'default'
  attribute :aws_access_key_id, :default => nil
  attribute :aws_secret_access_key, :default => nil
  attribute :region, :default => 'us-east-1'
end
