
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

    @service = Fog::Compute::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    vpcs = @service.vpcs.all('tag:Name' => new_resource.name)
    @collection = Fog::Compute::AWS::Vpcs.new(:service => @service)
    @current_resource_vpc = @collection.new(:id => new_resource.name, :service => @service)
    @current_resource_vpc.reload
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

    new_resource.tags['Name'] = new_resource.name

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource}")

    converge_if(@current_resource.id.nil?, "Create #{new_resource.resource_name}[#{new_resource.name}] from scratch") do
      create_attributes = [:cidr_block, :tenancy, :dhcp_options_id]
      create_attributes.each do |attr|
        value = new_resource.send(attr)
        Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
        @current_resource_vpc.send("#{attr}=", value) unless value.nil?
      end
      Chef::Log.debug("current_resource before save: #{current_resource}")
      result = @current_resource_vpc.save
      Chef::Log.debug("create as result: #{result}")

      new_resource.id(@current_resource_vpc.id)
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
