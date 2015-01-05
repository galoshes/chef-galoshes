
require_relative 'provider_base'

class Chef::Provider::GaloshesDnsRecord < Chef::Provider::GaloshesBase
  attr_reader :exists, :service, :collection

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/dns/records'

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']

    @service = Fog::DNS::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key)
    @collection = Fog::DNS::AWS::Records.new(:service => @service)
    @zone = new_resource.zone
    Chef::Log.debug("zone: #{@zone.inspect}")
    # Chef::Log.debug("zone.id: #{@zone.id}")
    @collection.zone = @zone
    # FIX    @fqdn = "#{new_resource.name}.#{@zone.name}"
    # FIX    @current_resource = @collection.new(:name => @fqdn)

    # FIX    reloaded = @current_resource.reload
    # FIX    @exists = !(reloaded.nil?)
    @exists = false
    # FIX    Chef::Log.debug("DnsRecord current_resource: #{@current_resource} exists: #{@exists}")
    # FIX    Chef::Log.debug(@current_resource.inspect)

    @current_resource
  end

  def action_create
    converge_if(!(@exists), "create #{new_resource.resource_name} for #{@fqdn}") do
      attributes = [:value, :ttl, :type, :alias_target, :region]
      attributes.each do |attr|
        value = new_resource.send(attr)
        Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
        @current_resource.send("#{attr}=", value) unless value.nil?
      end
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      @exists = true
      new_resource.updated_by_last_action(true)
    end
  end

  def action_delete
    converge_if(@exists, "delete #{resource_str}") do
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
