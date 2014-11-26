
require_relative 'provider_base'

class Chef::Provider::GaloshesAutoscalingGroup < Chef::Provider::GaloshesBase
  def load_current_resource
    require 'fog'
    require 'fog/aws/models/auto_scaling/groups'

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    region = new_resource.region || node['galoshes']['region']

    @fog_as = Fog::AWS::AutoScaling.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    @collection = Fog::AWS::AutoScaling::Groups.new(:service => @fog_as)
    @current_resource = @collection.new(:id => new_resource.name, :service => @fog_as)

    @current_resource.reload
    @exists = !(@current_resource.created_at.nil?)
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")
    Chef::Log.debug(@current_resource.inspect)
    Chef::Log.debug("instances: #{@current_resource.instances}")
    if @exists
      new_resource.instances(@current_resource.instances)
    end
    @current_resource
  end

  def action_create
    unless @exists
      converge_by("create #{resource_str}") do
        @collection.model.attributes.each do |attr|
          value = new_resource.send(attr)
          Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
          @current_resource.send("#{attr}=", value) unless value.nil?
        end
        Chef::Log.debug("current_resource before save: #{current_resource}")

        result = @current_resource.save
        Chef::Log.debug("create as result: #{result}")
        @exists = true
        new_resource.instances(@current_resource.instances) # FIX ME - is this necessary?
        new_resource.updated_by_last_action(true)
      end
    end
  end

  def action_delete
    if @exists
      converge_by("delete #{resource_str}") do
        @current_resource.destroy
        @exists = false
        new_resource.updated_by_last_action(true)
      end
    end
  end

  def action_update
    if @exists
      filtered_options = @current_resource.class.attributes - [:tags, :instances]
      Chef::Log.debug("filtered_options: #{filtered_options}")
      converged = true
      filtered_options.each do |attr|
        current_value = @current_resource.send(attr)
        new_value = new_resource.send(attr)
        Chef::Log.debug("attr: #{attr} current: #{current_value} new: #{new_value}")
        if !(new_value.nil?) && (current_value.to_s != new_value.to_s)
          converged = false
          converge_by("update #{resource_str}.#{attr} from #{current_value} to #{new_value}") do
            @current_resource.send("#{attr}=", new_value)
          end
        end
        Chef::Log.debug("checking #{attr} cur: #{current_value.inspect} new: #{new_value.inspect} converged: #{converged}")
      end

      converge_if(!converged, "updating #{resource_str}") do
        @current_resource.update
        new_resource.updated_by_last_action(true)
      end

      new_tags = new_resource.tags.map { |k, v| { 'ResourceId' => new_resource.name, 'PropagateAtLaunch' => true, 'Key' => k, 'Value' => v, 'ResourceType' => 'auto-scaling-group' } }
      Chef::Log.debug("tags cur: #{@current_resource.tags}")
      Chef::Log.debug("tags new: #{new_tags}")
      converge_if(new_tags != @current_resource.tags, "updating #{resource_str}.tags") do
        @fog_as.create_or_update_tags(new_tags)
        new_resource.updated_by_last_action(true)
      end

      new_resource.instances.each do |instance|
        instance_tags = new_resource.tags.merge('aws:autoscaling:groupName' => new_resource.name, 'Name' => "#{new_resource.name}-#{instance.id}")
        server = Chef::Resource::GaloshesServer.new("#{new_resource.name}-#{instance.id}", run_context)
        Chef::Log.debug("server: #{server.inspect}")
        server.region(new_resource.region)
        server.tags(instance_tags)
        server.security_group_ids(new_resource.launch_configuration.security_groups)
        server.run_action(:update)
      end

    end
  end
end
