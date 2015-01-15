require_relative 'provider_base'
require_relative 'service_dns'

class Chef::Provider::GaloshesDnsRecord < Chef::Provider::GaloshesBase
  include Galoshes::DnsService

  attr_reader :collection

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/dns/records'

    @collection = Fog::DNS::AWS::Records.new(:service => service)
    @zone = new_resource.zone
    Chef::Log.debug("zone: #{@zone.inspect}")
    @collection.zone = @zone

    @collection.all.each do |record|
      Chef::Log.debug "record: #{record.name}"
    end

    @fqdn = "#{new_resource.name}.#{@zone.domain}"
    @current_resource = @collection.new(:name => @fqdn, :service => service)
    @current_resource.reload
    Chef::Log.debug "current_resource after reload: #{@current_resource}"
    @exists = !(@current_resource.type.nil?)
    Chef::Log.debug("DnsRecord current_resource: #{@current_resource} exists: #{@exists} ready: #{@current_resource.status}")

    @current_resource
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      attributes = [:value, :ttl, :type, :alias_target, :region, :zone]
      copy_attributes(attributes)
      Chef::Log.debug("current_resource before save: #{current_resource}")
      # Chef::Log.debug "curr: #{@current_resource}"
      Chef::Log.debug "curr.zone: #{@current_resource.zone}"
      Chef::Log.debug "curr.zone.id: #{@current_resource.zone.id}"
      Chef::Log.debug "curr.zone: #{@current_resource.zone.inspect}"
      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      # Chef::Log.debug "current_resource after .save: #{@current_resource}"
      @exists = true
      new_resource.created_at(@current_resource.created_at)
      new_resource.updated_by_last_action(true)
    end
  end

  def action_delete
    converge_if(@exists, "delete #{resource_str}") do
      Chef::Log.debug "curr: #{@current_resource}"
      Chef::Log.debug "curr.zone: #{@current_resource.zone}"
      Chef::Log.debug "curr.zone.id: #{@current_resource.zone.id}"
      Chef::Log.debug "curr.zone: #{@current_resource.zone.inspect}"

      @current_resource.destroy
      @exists = false
      new_resource.updated_by_last_action(true)
    end
  end

  def action_update
    if @exists
      attributes = [:value, :ttl, :type, :alias_target, :region]
      Chef::Log.debug("attributes: #{attributes}")

      attributes.each do |attr|
        current_value = @current_resource.send(attr)
        new_value = new_resource.send(attr)
        Chef::Log.debug("checking #{attr} cur: #{current_value.inspect} new: #{new_value.inspect} equal? #{current_value.to_s == new_value.to_s}")
        converge_if(current_value.to_s != new_value.to_s, "updating #{resource_str}.#{attr} from #{current_value} to #{new_value}") do
          @current_resource.modify(attr => new_value)
          @current_resource.send("#{attr}=", new_value)
        end
      end

    end
  end
end
