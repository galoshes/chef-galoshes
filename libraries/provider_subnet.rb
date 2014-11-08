
class Chef::Provider::GaloshesSubnet < Chef::Provider::GaloshesBase

  def load_current_resource
    @current_resource ||= Chef::Resource::GaloshesSubnet.new(new_resource.name)

    if new_resource.vpc_id.nil?
      Chef::Log.debug("loading vpc_id from vpc")
      vpcs = Fog::Compute[:aws].vpcs.all('tag:Name' => new_resource.vpc)
      Chef::Log.debug("vpcs: #{vpcs.inspect}")
      if vpcs.size != 1
        Chef::Log.warn("Couldn't find vpc[#{new_resource.vpc}]. Found #{vpcs.size}")
      else
        Chef::Log.info("Found vpc[#{new_resource.vpc}]. Setting attributes.")
        new_resource.vpc_id(vpcs[0].id)
      end
    end
    Chef::Log.info("vpc_id: #{new_resource.vpc_id}")

    subnets = Fog::Compute[:aws].subnets.all('tag:Name' => new_resource.name, 'vpc-id' => new_resource.vpc_id)
    Chef::Log.debug("current: #{subnets.inspect}")
    if subnets.size != 1
      Chef::Log.warn("Couldn't find subnet[#{new_resource.name}]. Found #{subnets.size}")
    else
      Chef::Log.info("Found subnet[#{new_resource.name}]. Setting attributes.")
      @current_resource.id(subnets[0].subnet_id)
      @current_resource.vpc_id(subnets[0].vpc_id)
      @current_resource.cidr_block(subnets[0].cidr_block)
      @current_resource.availability_zone(subnets[0].availability_zone)
      @current_resource.tags(subnets[0].tag_set)
    end

    new_resource.tags['Name'] = new_resource.name

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")

    if @current_resource.id.nil?
      converge_by("Create #{new_resource.resource_name}[#{new_resource.name}] from scratch") do
        options = {}
        options['AvailabilityZone'] = new_resource.availability_zone unless new_resource.availability_zone.nil?
        result = con.create_subnet(new_resource.vpc_id, new_resource.cidr_block, options)
        if verify_result(result, "create_subnet(#{new_resource.vpc_id}, #{new_resource.cidr_block}, #{options}")
          subnet = result.body['subnet']
          @current_resource.id(subnet['subnetId'])
          @current_resource.vpc_id(subnet['vpcId'])
          @current_resource.cidr_block(subnet['cidrBlock'])
          @current_resource.availability_zone(subnet['availabilityZone'])
          @current_resource.tags(subnet['tagSet'])
        end
      end
    else
      Chef::Log.info("current_resource exists")
    end

    verify_attribute(:tags) {
      con.create_tags(@current_resource.id, new_resource.tags)
    }

  end

end
