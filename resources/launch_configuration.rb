
def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesLaunchConfiguration
end

actions :create, :delete
default_action :create

attribute :id, :kind_of => String, :name_attribute => true
attribute :image_id, :kind_of => String
attribute :instance_type, :kind_of => String
attribute :security_groups, :kind_of => Array
attribute :block_device_mappings, :kind_of => Array
attribute :kernel_id, :kind_of => String
attribute :ramdisk_id, :kind_of => String
attribute :user_data, :kind_of => String
attribute :key_name, :kind_of => String
attribute :placement_tenancy, :kind_of => String

attribute :aws_access_key_id, :default => nil
attribute :aws_secret_access_key, :default => nil
