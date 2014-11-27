# TODO
# validate in resource def that availability zone or subnet id, but not both set
# compare lists with set to make sure order doesn't matter

require 'ostruct'

class Chef::Provider::GaloshesLoadBalancer < Chef::Provider::GaloshesBase
  def load_current_resource
    @current_resource = OpenStruct.new
    @current_resource.connection = Fog::AWS::ELB.new(:region => new_resource.region)
    @current_resource.elb = @current_resource.connection.load_balancers.get(new_resource.name)

    Chef::Log.debug("current: #{@current_resource.elb.inspect}")
    Chef::Log.debug("current.listeners: #{@current_resource.elb.listeners}") unless @current_resource.elb.nil?

    Chef::Log.debug("subnet_ids: #{new_resource.subnet_ids}")
    if new_resource.subnet_ids.nil?
      Chef::Log.info('loading subnet_ids from subnets')
      new_resource.subnet_ids = new_resource.subnets.map { |subnet|
        s = run_context.resource_collection.find("galoshes_subnet[#{subnet}]")
        Chef::Log.debug("s: #{s.inspect}")
        Chef::Log.debug("s.subnet_id: #{s.subnet_id}")
        s.subnet_id
      }
    end
    Chef::Log.info("subnet_ids: #{new_resource.subnet_ids}")

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")
    con = @current_resource.connection

    cur_elb = @current_resource.elb

    converge_if(cur_elb.nil?, "Create ELB #{new_resource.name} from scratch") do
      options = {
        :scheme => new_resource.scheme,
        :subnet_ids => new_resource.subnet_ids,
        :security_groups => new_resource.security_groups,
      }
      result = con.create_load_balancer(new_resource.availability_zones, new_resource.name, new_resource.listeners, options)

      if result.status != 200
        Chef::Log.error('ELB creation failed!')
      else
        new_resource.updated_by_last_action(true)
      end
    end

    # verify subparts
    if cur_elb.nil? || new_resource.security_groups != cur_elb.security_groups
      Chef::Log.info('new.sg != cur.sg')
      converge_by "Updating security_groups to #{new_resource.security_groups}" do
        result = con.apply_security_groups(new_resource.security_groups, new_resource.name)
        verify_result(result.status, 'ELB apply_security_groups')
      end
    end

    if cur_elb.nil? || new_resource.subnet_ids != cur_elb.subnet_ids
      Chef::Log.info('new.subnet_ids != cur.subnet_ids')
      converge_by "Updating subnet_ids to #{new_resource.subnet_ids}" do
        result = con.enable_subnets(new_resource.subnet_ids, new_resource.name)
        verify_result(result.status, 'ELB enable_subnets')
      end
    end

    if cur_elb.nil? || new_resource.health_check != cur_elb.health_check
      Chef::Log.info('new.health_check != cur.health_check')
      converge_by "Updating health_check to #{new_resource.health_check}" do
        result = con.configure_health_check(new_resource.name, new_resource.health_check)
        verify_result(result.status, 'ELB configure_health_check')
      end
    end
  end
end
