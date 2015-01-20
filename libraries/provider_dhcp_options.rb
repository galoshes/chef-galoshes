require_relative 'service_compute'

class Chef::Provider::GaloshesDhcpOptions < Chef::Provider::GaloshesBase
  include Galoshes::ComputeService

  def load_current_resource
    @current_resource ||= Chef::Resource::GaloshesDhcpOptions.new(new_resource.name)

    @collection = Fog::Compute::AWS::DhcpOptions.new(:service => service)
    dhcp_options = @collection.all('tag:Name' => new_resource.name)

    Chef::Log.debug("current: #{dhcp_options.inspect}")
    if dhcp_options.size != 1
      Chef::Log.info("Couldn't find dhcp_option[#{new_resource.name}]. Found #{dhcp_options.size}")
      @exists = false
    else
      Chef::Log.info("Found dhcp_option[#{new_resource.name}]. Setting attributes.")
      current_resource.id(dhcp_options[0].id)
      @current_resource.configuration_set(dhcp_options[0].dhcp_configuration_set)
      @current_resource.tags(dhcp_options[0].tag_set)
      new_resource.id(@current_resource.id)

      @exists = true
    end

    # new_resource.tags['Name'] = new_resource.name
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      result = service.create_dhcp_options(new_resource.configuration_set)
      if verify_result(result, 'create_dhcp_options')
        body_set = result.body['dhcpOptionsSet']
        if body_set.size != 1
          Chef::Log.error("For some reason the result body didn't have 1 result Set #{result.body.inspect}")
        else
          @current_resource.id(body_set[0]['dhcpOptionsId'])
          @current_resource.configuration_set(body_set[0]['configurationSet'])
          @current_resource.tags(body_set[0]['tagSet'])

          new_resource.id(@current_resource.id)
        end
      end
    end
    Chef::Log.info("id: #{@current_resource.id}")

    verify_attribute(:tags) do
      service.create_tags(@current_resource.id, new_resource.tags)
    end
  end
end
