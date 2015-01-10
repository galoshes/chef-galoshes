# TODO
# validate in resource def that availability zone or subnet, but not both set
# compare lists with set to make sure order doesn't matter

class Chef::Provider::GaloshesLoadBalancer < Chef::Provider::GaloshesBase
  include Galoshes::DeleteMixin

  def load_current_resource
    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    @service = Fog::AWS::ELB.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => new_resource.region)
    @collection = Fog::AWS::ELB::LoadBalancers.new(:service => @service)
    @current_resource = @collection.new(:id => new_resource.name, :service => @service)
    Chef::Log.debug "curr: #{@current_resource}"
    @current_resource.reload
    Chef::Log.debug "curr.reload: #{@current_resource}"
    @exists = !(@current_resource.created_at.nil?)
    new_resource.glean_read_only_attributes(@current_resource) if @exists

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")

    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = [:id, :availability_zones, :security_groups, :scheme, :listeners, :subnet_ids, :health_check]
      create_attributes.each do |attr|
        value = new_resource.send(attr)
        Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
        @current_resource.send("#{attr}=", value) unless value.nil?
      end
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      @exists = true

      new_resource.glean_read_only_attributes(@current_resource)
      new_resource.updated_by_last_action(true)
    end
    action_update
  end

  def action_update
    verify_attribute(:security_groups, false) do
      @service.apply_security_groups(new_resource.security_groups, @current_resource.id)
      @current_resource.security_groups = new_resource.security_groups
      new_resource.updated_by_last_action(true)
    end
  end
end
