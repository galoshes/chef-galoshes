require_relative 'provider_base'

class Chef::Provider::GaloshesLaunchConfiguration < Chef::Provider::GaloshesBase
  include Galoshes::AutoscalingService

  def clarify_attributes
    # @current_resource.placement_tenancy ||= 'default'
  end

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/auto_scaling/configurations'

    @collection = Fog::AWS::AutoScaling::Configurations.new(:service => service)
    @current_resource = @collection.new(:id => new_resource.name, :service => service)

    @current_resource.reload
    clarify_attributes
    @exists = !(@current_resource.created_at.nil?)
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")

    @current_resource
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = [:id, :image_id, :instance_type, :security_groups, :block_device_mappings, :key_name, :user_data, :kernel_id, :ramdisk_id,] # :placement_tenancy]
      copy_attributes(create_attributes)
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      @exists = !(result.nil?)
      clarify_attributes
      new_resource.updated_by_last_action(true)
    end
    verify_attribute(:user_data, false) { new_resource.updated_by_last_action(true) }
  end

  def action_delete
    converge_if(@exists, "delete #{resource_str}") do
      @current_resource.destroy
      @exists = false
      new_resource.updated_by_last_action(true)
    end
  end

  def action_update
    update_attributes = [:id, :image_id, :instance_type, :block_device_mappings, :key_name, :kernel_id, :ramdisk_id,] # :placement_tenancy]
    update_attributes.each do |attr|
      verify_attribute(attr) {}
    end

    Chef::Log.info("verify #{resource_str}.security_groups")
    current_value = @current_resource.security_groups.sort unless @current_resource.security_groups.nil?
    new_value = new_resource.security_groups.sort unless @new_resource.security_groups.nil?
    Chef::Log.info("#{resource_str}.security_groups cur: #{current_value.inspect} new: #{new_value.inspect}")
    converge_if(current_value != new_value, "update '#{resource_str}.security_groups from '#{current_value}' to '#{new_value}'") {}

    # FIX ME - :user_data needs to be added, but is broken in fog
  end
end
