require 'pp'
require_relative 'provider_base'

class Chef::Provider::GaloshesSecurityGroup < Chef::Provider::GaloshesBase
  include Galoshes::DeleteMixin

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/compute/security_groups'

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    region = new_resource.region || node['galoshes']['region']

    @fog_as = Fog::Compute::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    @collection = Fog::Compute::AWS::SecurityGroups.new(:service => @fog_as)
    @current_resource = @collection.get(new_resource.name)

    @exists = !(@current_resource.nil?)
    @current_resource.reload if @exists
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")
    if @exists
      new_resource.group_id(@current_resource.group_id)
    end

    @current_resource
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      @current_resource = @collection.new
      create_attributes = [:name, :description, :group_id, :ip_permissions, :ip_permissions_egress, :vpc_id]
      copy_attributes(create_attributes)
      Chef::Log.debug("current_resource before save: #{@current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      Chef::Log.debug("current_resource after save: #{@current_resource}")
      @exists = true

      @current_resource.reload
      Chef::Log.debug("current_resource after reload: #{@current_resource}")

      authorize_ip_permissions

      new_resource.group_id(@current_resource.group_id)
      new_resource.updated_by_last_action(true)
    end
  end

  def authorize_ip_permissions
    Chef::Log.info("new_resource.ip_permissions: #{new_resource.ip_permissions}")
    Chef::Log.info("current_reso.ip_permissions: #{@current_resource.ip_permissions}")
    new_ip_permissions = new_resource.ip_permissions.map do |p|
      perm = {}
      perm[:range] = p[:range].is_a?(Fixnum) ? (p[:range]..p[:range]) : p[:range]
      perm[:ip_protocol] = p.include?(:ip_protocol) ? p[:ip_protocol] : 'tcp'
      if p.include?(:group)
        perm[:group] = (p[:group] == :self) ? @current_resource.group_id : p[:group]
      end
      perm[:cidr_ip] = p[:cidr_ip] if p.include?(:cidr_ip)
      perm
    end

    cur_ip_permissions = @current_resource.ip_permissions.map do |p|
      perm = {}
      perm[:range] = (p['fromPort']..p['toPort'])
      perm[:ip_protocol] =  p['ipProtocol']
      perm[:cidr_ip] = p['ipRanges'][0]['cidrIp'] if p['ipRanges'].size > 0
      perm[:group] = p['groups'][0]['groupId'] if p['groups'].size > 0
      perm
    end

    Chef::Log.info("new_ip: #{new_ip_permissions}")
    Chef::Log.info("cur_ip: #{cur_ip_permissions}")

    remove_permissions = cur_ip_permissions - new_ip_permissions
    authorize_permissions = new_ip_permissions - cur_ip_permissions

    remove_permissions.each do |permission|
      converge_by("remove #{permission}") do
        @current_resource.revoke_port_range(permission[:range], permission)
        new_resource.updated_by_last_action(true)
      end
    end

    authorize_permissions.each do |permission|
      converge_by("add #{permission}") do
        @current_resource.authorize_port_range(permission[:range], permission)
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
