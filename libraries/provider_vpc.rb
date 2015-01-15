
class Chef::Provider::GaloshesVpc < Chef::Provider::GaloshesBase
  def load_current_resource
    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    region = new_resource.region || node['galoshes']['region']

    @service = Fog::Compute::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    @collection = Fog::Compute::AWS::Vpcs.new(:service => @service)
    vpcs = @collection.all('tag:Name' => new_resource.name)
    @current_resource = @collection.new(:id => new_resource.name, :service => @service)
    @current_resource.reload
    Chef::Log.debug("vpcs: #{vpcs.to_json}")
    if vpcs.size != 1
      Chef::Log.info("Couldn't find vpc[#{new_resource.name}]. Found #{vpcs.size}")
      @exists = false
    else
      Chef::Log.info("Found vpc[#{new_resource.name}]. Setting attributes.")
      @exists = true
      @current_resource = vpcs[0]
    end
    Chef::Log.debug("load_current_resource @current_resource: #{@current_resource.to_json}")

    new_resource.tags['Name'] = new_resource.name
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource}")

    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = [:cidr_block, :tenancy, :dhcp_options_id, :tags, :dhcp_options_id,]
      copy_attributes(create_attributes)
      Chef::Log.debug("current_resource before save: #{current_resource}")
      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")

      new_resource.id(@current_resource.id)
    end
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
