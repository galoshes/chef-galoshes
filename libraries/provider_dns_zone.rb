
require_relative 'provider_base'

class Chef::Provider::GaloshesDnsZone < Chef::Provider::GaloshesBase
  include Galoshes::DeleteMixin

  attr_reader :service, :collection

  def load_current_resource
    require 'fog'
    require 'fog/aws/models/dns/zones'

    aws_access_key_id = new_resource.aws_access_key_id || node['galoshes']['aws_access_key_id']
    aws_secret_access_key = new_resource.aws_secret_access_key || node['galoshes']['aws_secret_access_key']

    @service = Fog::DNS::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key)
    @collection = Fog::DNS::AWS::Zones.new(:service => @service)
    all = @collection.all
    @current_resource = all.find { |zone| zone.domain == new_resource.domain }

    @exists = !(@current_resource.nil?)
    Chef::Log.debug("#{resource_str} current_resource: #{@current_resource} exists: #{@exists}")

    if @exists
      new_resource.id(@current_resource.id)
    end

    @current_resource
  end

  def action_create
    converge_unless(@exists, "create #{resource_str}") do
      @current_resource = Fog::DNS::AWS::Zone.new(:service => @service)
      create_attributes = [:domain, :description, :nameservers]
      create_attributes.each do |attr|
	Chef::Log.debug("attr: #{attr}")
	value = new_resource.send(attr)
	Chef::Log.debug("attr: #{attr} value: #{value} nil? #{value.nil?}")
	@current_resource.send("#{attr}=", value) unless value.nil?
      end
      Chef::Log.debug("current_resource before save: #{current_resource}")

      result = @current_resource.save
      Chef::Log.debug("create as result: #{result}")
      @exists = true
      new_resource.id(@current_resource.id)
      new_resource.updated_by_last_action(true)
    end
  end

  def action_update
    if @exists
      filtered_options = @current_resource.class.attributes
      Chef::Log.debug("filtered_options: #{filtered_options}")
      converged = true
      filtered_options.each do |attr|
        current_value = @current_resource.send(attr)
        new_value = new_resource.send(attr)
        if !(new_value.nil?) && (current_value != new_value)
          converged = false
          converge_by("Updating #{resource_str}.#{attr}") do
            @current_resource.send("#{attr}=", new_value)
          end
        end
        Chef::Log.debug("checking #{attr} cur: #{current_value} new: #{new_value} converged: #{converged}")
      end

      unless converged
        converge_by("Updating #{resource_str}") do
          @current_resource.update
          new_resource.updated_by_last_action(true)
        end
      end
    end
  end
end
