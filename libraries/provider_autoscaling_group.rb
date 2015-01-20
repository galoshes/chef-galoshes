require_relative 'provider_base'
require_relative 'service_auto_scaling'

class Chef::Provider::GaloshesAutoscalingGroup < Chef::Provider::GaloshesBase
  include Galoshes::DeleteMixin
  include Galoshes::AutoscalingService

  def collection
    require 'fog'
    require 'fog/aws/models/auto_scaling/groups'
    Fog::AWS::AutoScaling::Groups.new(:service => service)
  end

  def load_current_resource
    @current_resource = collection.new(:id => new_resource.name, :service => service)
    @current_resource.reload
    @exists = !(@current_resource.created_at.nil?)
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource.to_json} exists: #{@exists}")
    Chef::Log.debug("instances: #{@current_resource.instances.to_json}")

    new_resource.instances(@current_resource.instances)
    new_resource.launch_configuration_name = new_resource.launch_configuration.name
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = collection.model.attributes
      copy_attributes(create_attributes)
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      @exists = true
      new_resource.instances(@current_resource.instances) # FIX ME - is this necessary?
      new_resource.updated_by_last_action(true)
    end
  end

  def action_update
    if @exists
      filtered_options = @current_resource.class.attributes + [:launch_configuration_name] - [:tags, :instances, :created_at, :arn]
      Chef::Log.debug("filtered_options: #{filtered_options}")
      converged = true
      filtered_options.each do |attr|
        verify_attribute(attr, false) do
          value = new_resource.send(attr)
          Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
          @current_resource.send("#{attr}=", value) unless value.nil?
          converged = false
        end
      end

      converge_if(!converged, "updating #{resource_str}") do
        @current_resource.update
        new_resource.updated_by_last_action(true)
      end

      unless new_resource.tags.nil?
        new_tags = new_resource.tags.map { |k, v| { 'ResourceId' => new_resource.name, 'PropagateAtLaunch' => true, 'Key' => k, 'Value' => v, 'ResourceType' => 'auto-scaling-group' } }
        Chef::Log.debug("tags cur: #{@current_resource.tags}")
        Chef::Log.debug("tags new: #{new_tags}")
        converge_if(new_tags != @current_resource.tags, "updating #{resource_str}.tags") do
          service.create_or_update_tags(new_tags) unless Fog.mocking?
          new_resource.updated_by_last_action(true)
        end
      end

      new_resource.servers = []
      new_resource.instances.each do |instance|
        instance_tags = new_resource.tags.merge('Name' => "#{new_resource.name}-#{instance.id}")
        server = Chef::Resource::GaloshesServer.new(instance.id, run_context)
        Chef::Log.debug("server: #{server.inspect}")
        server.filter_by('instance-id')
        server.region(new_resource.region)
        server.tags(instance_tags)
        server.security_group_ids(new_resource.launch_configuration.security_groups)
        server.run_action(:update)
        new_resource.servers << server
      end

    end
  end
end
