require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesDnsZone < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_dns_zone

  actions :create, :delete, :update
  default_action :create

  attribute :domain, :name_attribute => true
  attribute :id
  attribute :description
  attribute :nameservers

  attribute :aws_access_key_id, :kind_of => [String, NilClass], :default => nil
  attribute :aws_secret_access_key, :kind_of => [String, NilClass], :default => nil
end
