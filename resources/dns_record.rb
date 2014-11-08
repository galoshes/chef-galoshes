
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesDnsRecord
end

actions :create, :delete, :update
default_action :create

attribute :name, :name_attribute => true

attribute :value, :kind_of => Array
attribute :ttl
attribute :type
attribute :status
attribute :created_at
attribute :alias_target
attribute :change_id
attribute :region
attribute :weight
attribute :set_identifier
attribute :failover
attribute :geo_location
attribute :health_check_id

attribute :zone

attribute :aws_access_key_id, :default => nil
attribute :aws_secret_access_key, :default => nil
