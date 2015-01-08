
class Chef::Provider::GaloshesVpc < Chef::Provider::GaloshesBase
  def load_attributes
    result = con.describe_vpc_attribute(@current_resource.id, 'enableDnsSupport')
    if result.status == 200
      @current_resource.enable_dns_support(result.body['enableDnsSupport'])
    end
    result = con.describe_vpc_attribute(@current_resource.id, 'enableDnsHostnames')
    if result.status == 200
      @current_resource.enable_dns_hostnames(result.body['enableDnsHostnames'])
    end
  end

  def load_current_resource
    @current_resource ||= Chef::Resource::GaloshesVpc.new(new_resource.name)

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    region = new_resource.region || node['galoshes']['region']

    @fog_as = Fog::Compute.new(:provider => 'AWS', :aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    vpcs = @fog_as.vpcs.all('tag:Name' => new_resource.name)
    Chef::Log.debug("current: #{vpcs.inspect}")
    if vpcs.size != 1
      Chef::Log.info("Couldn't find vpc[#{new_resource.name}]. Found #{vpcs.size}")
      @exists = false
    else
      Chef::Log.info("Found vpc[#{new_resource.name}]. Setting attributes.")
      @exists = true
      @current_resource.id(vpcs[0].id)
      @current_resource.cidr_block(vpcs[0].cidr_block)
      @current_resource.dhcp_options_id(vpcs[0].dhcp_options_id)
      @current_resource.tenancy(vpcs[0].tenancy)
      @current_resource.tags(vpcs[0].tags)

      load_attributes
    end

    if new_resource.dhcp_options_id.nil?
      Chef::Log.debug('loading dhcp_options_id from dhcp_options attribute')

      dhcp_options = Fog::Compute[:aws].dhcp_options.all('tag:Name' => new_resource.dhcp_options)
      Chef::Log.debug("dhcp_options: #{dhcp_options.inspect}")
      if dhcp_options.size != 1
        Chef::Log.info("Couldn't find dhcp_option[#{new_resource.dhcp_options}]. Found #{dhcp_options.size}")
      else
        Chef::Log.info("Found dhcp_option[#{new_resource.dhcp_options}]. Setting attributes.")
        new_resource.dhcp_options_id(dhcp_options[0].id)
      end
    end
    Chef::Log.info("dhcp_options_id: #{new_resource.dhcp_options_id}")

    new_resource.tags['Name'] = new_resource.name

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")

    converge_if(@current_resource.id.nil?, "Create #{new_resource.resource_name}[#{new_resource.name}] from scratch") do
      result = con.create_vpc(new_resource.cidr_block, 'InstanceTenancy' => new_resource.tenancy)
      if verify_result(result, "create_vpc(#{new_resource.cidr_block}) #{new_resource.name}")
        body_set = result.body['vpcSet']
        if body_set.size != 1
          Chef::Log.error("For some reason the result body didn't have 1 result Set #{result.body.inspect}")
        else
          @current_resource.id(body_set[0]['vpcId'])
          @current_resource.cidr_block(body_set[0]['cidrBlock'])
          @current_resource.dhcp_options_id(body_set[0]['dhcpOptionsId'])
          @current_resource.tenancy(body_set[0]['instanceTenancy'])
          @current_resource.tags(body_set[0]['tagSet'])
          load_attributes
        end
        Chef::Log.info("id: #{@current_resource.id}")
      end
    end

    action_update
  end

  def action_update
    verify_attribute(:tags) do
      con.create_tags(@current_resource.id, new_resource.tags)
    end

    verify_attribute(:dhcp_options_id) do
      con.associate_dhcp_options(new_resource.dhcp_options_id, @current_resource.id)
    end

    verify_attribute(:enable_dns_support) do
      con.modify_vpc_attribute(@current_resource.id, 'EnableDnsSupport.Value' => new_resource.enable_dns_support)
    end

    verify_attribute(:enable_dns_hostnames) do
      con.modify_vpc_attribute(@current_resource.id, 'EnableDnsHostnames.Value' => new_resource.enable_dns_hostnames)
    end

    verify_attribute(:tenancy) do
      OpenStruct.new(:status => "Cannot update the tenancy on VPCs to #{new_resource.tenancy}")
    end
  end
end
