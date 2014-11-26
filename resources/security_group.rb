
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesSecurityGroup
end

actions :create, :delete, :update
default_action :create

attribute :name, :kind_of => String, :name_attribute => true

attribute :description, :kind_of => String
attribute :group_id, :kind_of => String
attribute :ip_permissions, :kind_of => Array
attribute :ip_permissions_egress, :kind_of => Array
attribute :owner_id, :kind_of => String
attribute :vpc_id, :kind_of => String

attribute :aws_access_key_id, :default => nil
attribute :aws_secret_access_key, :default => nil
attribute :region, :default => 'us-east-1'
