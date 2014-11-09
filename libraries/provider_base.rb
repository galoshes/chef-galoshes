
class Chef
  class Provider

    class GaloshesBase < Chef::Provider

      def con
        require 'fog'
        @con ||= Fog::Compute[:aws]
        @con
      end

      def whyrun_supported?
        true
      end

      def action_create
        Chef::Log.info("action_create")
      end

      def resource_str
        "#{new_resource.resource_name}[#{new_resource.name}]"
      end

      def converge_if(condition, message, &block)
        if condition
	  converge_by(message, &block)
	end
      end

      def verify_result(result, msg)
        Chef::Log.debug("result: #{result.status}")
        if result.status != 200
          Chef::Log.error(msg + " fail status: #{result.status}")
          return false
        else
          Chef::Log.info(msg + " success")
          new_resource.updated_by_last_action(true)
          return true
        end
      end

      def verify_attribute(attribute_sym, &fix_the_attribute)
        Chef::Log.info("verify #{new_resource.resource_name}[#{new_resource.name}].#{attribute_sym}")

        current_value = @current_resource.send(attribute_sym)
        Chef::Log.debug("current_value: #{current_value}")

        new_value = new_resource.send(attribute_sym)
        Chef::Log.debug("new_value: #{new_value}")

        converge_if(current_value != new_value, "Updating '#{new_resource.resource_name}[#{new_resource.name}].#{attribute_sym}' from #{current_value} to #{new_value}" do
          result = fix_the_attribute.call
          verify_result(result, "'#{new_resource.resource_name}[#{new_resource.name}].#{attribute_sym}' (#{fix_the_attribute})")
        end
      end
    end

    require_relative 'provider_dhcp_options'
    require_relative 'provider_vpc'
    require_relative 'provider_subnet'
    require_relative 'provider_load_balancer'

  end
end