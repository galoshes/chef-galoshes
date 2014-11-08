
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesDnsZone
end

actions :create, :delete, :update
default_action :create

attribute :domain, :name_attribute => true
attribute :id
attribute :description
attribute :nameservers

attribute :aws_access_key_id, :kind_of => [String, NilClass], :default => nil
attribute :aws_secret_access_key, :kind_of => [String, NilClass], :default => nil
