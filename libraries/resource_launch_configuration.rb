require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesLaunchConfiguration < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_launch_configuration

  actions :create, :delete, :update
  default_action :create

  attribute :id, :kind_of => String, :name_attribute => true
  attribute :image_id, :kind_of => String
  attribute :instance_type, :kind_of => String
  attribute :security_groups, :kind_of => Array
  attribute :block_device_mappings, :kind_of => Array, :default => []
  attribute :kernel_id, :kind_of => String
  attribute :ramdisk_id, :kind_of => String
  attribute :user_data, :kind_of => String
  attribute :key_name, :kind_of => String
  attribute :placement_tenancy, :kind_of => String, :default => 'default'

  attribute :aws_access_key_id, :default => nil
  attribute :aws_secret_access_key, :default => nil
  attribute :region, :default => 'us-east-1'
end
