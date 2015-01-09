# TODO
# validate in resource def that availability zone or subnet, but not both set
# compare lists with set to make sure order doesn't matter

require 'ostruct'

class Chef::Provider::GaloshesLoadBalancer < Chef::Provider::GaloshesBase
  include Galoshes::DeleteMixin

  def load_current_resource
    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    @service = Fog::AWS::ELB.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => new_resource.region)
    @collection = Fog::AWS::ELB::LoadBalancers.new(:service => @service)
    @current_resource = @collection.new(:id => new_resource.name, :service => @service)
#puts "curr: #{@current_resource}"
    @current_resource.reload
#puts "curr.reload: #{@current_resource}"
    @exists = !(@current_resource.created_at.nil?)
    if @exists
    end
    
    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")

    unless @exists
      converge_by("create #{resource_str}") do
        create_attributes = [:id, :availability_zones, :security_groups, :scheme, :listeners, :subnet_ids ]
        create_attributes.each do |attr|
          value = new_resource.send(attr)
          Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
          @current_resource.send("#{attr}=", value) unless value.nil?
        end
        Chef::Log.debug("current_resource before save: #{current_resource}")

        result = @current_resource.save
        Chef::Log.debug("create as result: #{result}")
        @exists = true

        read_only_attributes = [:created_at, :dns_name, :instances]
        read_only_attributes.each do |attr|
          value = @current_resource.send(attr)
          Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
          new_resource.send(attr, value) unless value.nil?
        end

        new_resource.updated_by_last_action(true)

      end
    end
  end

  def foo
    converge_if(@current_resource.nil?, "Create ELB #{new_resource.name} from scratch") do
      options = {
        :scheme => new_resource.scheme,
        :subnet_ids => new_resource.subnets,
        :security_groups => new_resource.security_groups,
      }
      #result = @service.create_load_balancer(new_resource.availability_zones, new_resource.name, new_resource.listeners, options)

      #if result.status != 200
      #  Chef::Log.error('ELB creation failed!')
      #else
      #  new_resource.updated_by_last_action(true)
      #end
    end

    # verify subparts
    if @current_resource.nil? || new_resource.security_groups != @current_resource.security_groups
      Chef::Log.info('new.sg != cur.sg')
#puts "new.sg: #{new_resource.security_groups}"
#puts "cur.sg: #{@current_resource.security_groups}" unless @current_resource.nil?
      missing_security_groups = new_resource.security_groups
      missing_security_groups -= @current_resource.security_groups unless @current_resource.nil?
#puts "missing: #{missing_security_groups}"
      converge_by "Updating security_groups to #{new_resource.security_groups}" do
        result = @service.apply_security_groups(missing_security_groups, new_resource.name)
        verify_result(result, 'ELB apply_security_groups')
      end
    end

    if @current_resource.nil? || new_resource.subnets != @current_resource.subnet_ids
      Chef::Log.info('new.subnets != cur.subnet_ids')
      converge_by "Updating subnets to #{new_resource.subnets}" do
        result = @service.enable_subnets(new_resource.subnets, new_resource.name)
        verify_result(result, 'ELB enable_subnets')
      end
    end

    if @current_resource.nil? || new_resource.health_check != @current_resource.health_check
      Chef::Log.info('new.health_check != cur.health_check')
      converge_by "Updating health_check to #{new_resource.health_check}" do
        result = @service.configure_health_check(new_resource.name, new_resource.health_check)
        verify_result(result, 'ELB configure_health_check')
      end
    end
  end
end
