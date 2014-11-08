
require_relative 'provider_base'

class Chef::Provider::GaloshesSecurityGroup < Chef::Provider::GaloshesBase

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/compute/security_groups'

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']

    @fog_as = Fog::Compute::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key)
    @collection = Fog::Compute::AWS::SecurityGroups.new(:service => @fog_as)
    @current_resource = @collection.new({ :name => new_resource.name, :service => @fog_as })

    @current_resource.reload
    @exists = !(@current_resource.group_id.nil?)
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")
    Chef::Log.debug(@current_resource.inspect)

    @current_resource
  end

  def action_create
    if !(@exists)
      converge_by("create #{resource_str}") do
        @collection.model.attributes.each do |attr|
          value = new_resource.send(attr)
          Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
	  @current_resource.send("#{attr}=", value) unless value.nil?
        end
        Chef::Log.debug("current_resource before save: #{current_resource.inspect}")

	result = @current_resource.save
	Chef::Log.debug("create as result: #{result}")
	Chef::Log.debug("current_resource after save: #{current_resource.inspect}")
	@exists = true

	@current_resource.reload
	Chef::Log.debug("current_resource after reload: #{current_resource.inspect}")

        authorize_ip_permissions

	new_resource.updated_by_last_action(true)
      end
    end
  end

  def authorize_ip_permissions
    Chef::Log.debug("new_resource.ip_permissions: #{new_resource.ip_permissions}")
    Chef::Log.debug("current_reso.ip_permissions: #{@current_resource.ip_permissions}")
    new_ip_permissions = new_resource.ip_permissions.map { |p|
      perm = {}
      perm[:range] = p[:range].is_a?(Fixnum) ? (p[:range]..p[:range]) : p[:range]
      perm[:ip_protocol] = p.include?(:ip_protocol) ? p[:ip_protocol] : 'tcp'
      perm[:group] = p[:group] == :self ? @current_resource.group_id : p[:group]
      perm
    }

    cur_ip_permissions = @current_resource.ip_permissions.map { |p|
      permission = {}
      permission[:range] = (p['fromPort']..p['toPort'])
      permission[:ip_protocol] =  p['ipProtocol']

      if p['groups'].size > 0
	permission[:group] = p['groups'][0]['groupId']
      end

      permission
    }

    Chef::Log.debug("new_ip: #{new_ip_permissions}")
    Chef::Log.debug("cur_ip: #{cur_ip_permissions}")

    cur_ip_permissions.each do |cur_permission|
      converge_if( !(new_ip_permissions.include?(cur_permission)), "remove #{cur_permission}" ) do
        @current_resource.revoke_port_range(cur_permission[:range], cur_permission)
        new_resource.updated_by_last_action(true)
      end
    end

    new_ip_permissions.each do |new_permission|
      converge_if( !(cur_ip_permissions.include?(new_permission)), "add #{new_permission}" ) do
        @current_resource.authorize_port_range(new_permission[:range], new_permission)
        new_resource.updated_by_last_action(true)
      end
    end
  end

  def action_delete
    if @exists
      converge_by("delete #{resource_str}") do
	@current_resource.destroy()
        @exists = false
        new_resource.updated_by_last_action(true)
      end
    end
  end

  def action_update
    if @exists
      authorize_ip_permissions
    end
  end

end
