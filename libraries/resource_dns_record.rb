require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesDnsRecord < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_dns_record

  actions :create, :delete, :update
  default_action :create

  attribute :name, :name_attribute => true

  attribute :zone, :required => true
  attribute :type, :required => true

  # one of these is required
  attribute :alias_target
  attribute :value, :kind_of => Array

  # if value is set, this is required
  attribute :ttl

  attribute :status
  attribute :created_at
  attribute :change_id
  attribute :region
  attribute :weight
  attribute :set_identifier
  attribute :failover
  attribute :geo_location
  attribute :health_check_id

  attribute :aws_access_key_id, :default => nil
  attribute :aws_secret_access_key, :default => nil
end
