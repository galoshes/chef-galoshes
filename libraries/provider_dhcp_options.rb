
class Chef::Provider::GaloshesDhcpOptions < Chef::Provider::GaloshesBase

  def load_current_resource
    @current_resource ||= Chef::Resource::GaloshesDhcpOptions.new(new_resource.name)

    dhcp_options = Fog::Compute[:aws].dhcp_options.all('tag:Name' => new_resource.name)
    Chef::Log.debug("current: #{dhcp_options.inspect}")
    if dhcp_options.size != 1
      Chef::Log.warn("Couldn't find dhcp_option[#{new_resource.name}]. Found #{dhcp_options.size}")
    else
      Chef::Log.info("Found dhcp_option[#{new_resource.name}]. Setting attributes.")
      @current_resource.id(dhcp_options[0].id)
      @current_resource.configuration_set(dhcp_options[0].dhcp_configuration_set)
      @current_resource.tags(dhcp_options[0].tag_set)
    end

    new_resource.tags['Name'] = new_resource.name

    @current_resource
  end

  def action_create
    Chef::Log.debug("new_resource: #{new_resource.inspect}")

    if @current_resource.id.nil?
      converge_by("Create #{new_resource.resource_name}[#{new_resource.name}] from scratch") do
        result = con.create_dhcp_options(new_resource.configuration_set)
        if verify_result(result, "create_dhcp_options")
          bodySet = result.body['dhcpOptionsSet']
          if bodySet.size != 1
            Chef::Log.error("For some reason the result body didn't have 1 result Set #{result.body.inspect}")
          else
            @current_resource.id(bodySet[0]['dhcpOptionsId'])
            @current_resource.configuration_set(bodySet[0]['configurationSet'])
            @current_resource.tags(bodySet[0]['tagSet'])
          end
          Chef::Log.info("id: #{@current_resource.id}")
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