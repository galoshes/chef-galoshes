
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesServer
end

actions :create, :delete, :update
default_action :create

## the name/id is kinda overloaded.  it's a unique way of filtering the server
## filter_by can be any AWS filter and defaults to the tag:Name, but can also be instanceId or others
## whatever the first one that comes back gets used
attribute :id, :name_attribute => true
attribute :filter_by, :default => 'tag:Name'

attribute :tags, :kind_of => Hash
attribute :groups, :kind_of => Array
attribute :security_group_ids, :kind_of => Array
attribute :private_ip_address, :kind_of => String

attribute :aws_access_key_id, :default => nil
attribute :aws_secret_access_key, :default => nil
attribute :region, :default => 'us-east-1'
