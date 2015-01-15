
class Chef::Provider::GaloshesSubnet < Chef::Provider::GaloshesBase
  def load_current_resource
    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']
    region = new_resource.region || node['galoshes']['region']

    @service = Fog::Compute::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    @collection = Fog::Compute::AWS::Subnets.new(:service => @service)

    Chef::Log.info("vpc_id: #{new_resource.vpc_id}")

    if new_resource.subnet_id
      @current_resource = @collection.get(new_resource.subnet_id)
      @exists = !(@current_resource.nil?)
    else
      subnets = @collection.all('tag:Name' => new_resource.name, 'vpc-id' => new_resource.vpc_id)

      if subnets.size == 1
        Chef::Log.debug("Found #{resource_str}.")
        @current_resource = subnets[0]
        @exists = true
        Chef::Log.debug("Found cur: #{@current_resource.to_json}")
      else
        Chef::Log.debug("Couldn't find #{resource_str}. Found #{subnets.size}")
        @exists = false
      end
    end
    @current_resource = @collection.new unless @exists
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource}")

    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = [:cidr_block, :availability_zone, :vpc_id, :tag_set]
      create_attributes.each do |attr|
        value = new_resource.send(attr)
        Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
        @current_resource.send("#{attr}=", value) unless value.nil?
      end
      Chef::Log.debug("current_resource before save: #{current_resource}")
      result = @current_resource.save
      @current_resource.reload
      Chef::Log.debug("create as result: #{result} after save #{current_resource}")
    end
    verify_attribute(:tag_set) do
      @service.create_tags(@current_resource.subnet_id, new_resource.tag_set) unless Fog.mocking?
    end
  end
end
