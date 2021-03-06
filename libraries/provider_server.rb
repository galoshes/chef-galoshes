require_relative 'provider_base'
require_relative 'service_compute'

class Chef::Provider::GaloshesServer < Chef::Provider::GaloshesBase
  include Galoshes::ComputeService

  def load_current_resource
    require 'fog'

    @collection = service.servers
    @current_resource = @collection.all(new_resource.filter_by => new_resource.name).first

    @exists = !(@current_resource.nil?)
    Chef::Log.info("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")
    Chef::Log.debug(@current_resource)

    if @exists
      new_resource.private_ip_address(@current_resource.private_ip_address)
    else
      @current_resource = @collection.new
    end
    @current_resource
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      create_attributes = [:groups, :security_group_ids]
      copy_attributes(create_attributes)
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      @exists = true
      new_resource.updated_by_last_action(true)
    end
  end

  def action_delete
  end

  def action_update
    if @exists
      Chef::Log.info("tags cur: #{@current_resource.tags}")
      Chef::Log.info("tags new: #{new_resource.tags}")
      new_tags = new_resource.tags.reject { |k, _| @current_resource.tags.include?(k) || k.match(/^aws/) }
      Chef::Log.info("new_tags: #{new_tags}")
      converge_if(new_tags.size > 0, "add tags: #{new_tags}") {}

      update_tags = new_resource.tags.select { |k, v| @current_resource.tags.include?(k) && @current_resource.tags[k] != v && !k.match(/^aws/) }
      update_tags.each do |tag, value|
        converge_by("update tag #{tag} from #{@current_resource.tags[tag]} to #{value}") {}
      end
      changes = new_tags.merge(update_tags)
      converge_if(changes.size > 0, 'call create_tags') do
        result = @current_resource.service.create_tags([@current_resource.id], new_tags.merge(update_tags))
        Chef::Log.info("result: #{result.inspect}")
        new_resource.updated_by_last_action(true)
      end

      delete_tags = @current_resource.tags.reject { |k, _| new_resource.tags.include?(k) || k.match(/^aws/) }
      Chef::Log.info("delete_tags: #{delete_tags}")
      converge_if(delete_tags.size != 0, "removing tags: #{delete_tags}") do
        result = @current_resource.service.delete_tags([@current_resource.id], delete_tags)
        verify_result(result)
      end

      cur_groups = @current_resource.security_group_ids
      new_groups = new_resource.security_group_ids
      cur_groups.sort! unless cur_groups.nil?
      new_groups.sort! unless new_groups.nil?
      Chef::Log.info("security_groups cur: #{cur_groups}")
      Chef::Log.info("security_groups new: #{new_groups}")
      converge_if(!(new_groups.nil?) && cur_groups != new_groups, "update security groups from #{cur_groups} to #{new_groups}") do
        result = service.modify_instance_attribute(@current_resource.id, 'GroupId' => new_groups)
        Chef::Log.info("result: #{result.status}")
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
