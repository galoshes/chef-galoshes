
class Chef
  class Provider
    class GaloshesBase < Chef::Provider
      attr_reader :exists

      def con
        require 'fog'
        @con ||= Fog::Compute[:aws]
        @con
      end

      def whyrun_supported?
        true
      end

      def action_create
        Chef::Log.info('action_create')
      end

      def resource_str
        "#{new_resource.resource_name}[#{new_resource.name}]"
      end

      def converge_if(condition, message, &block)
        if condition
          converge_by(message, &block)
        end
      end

      def converge_unless(condition, message, &block)
        unless condition
          converge_by(message, &block)
        end
      end

      def verify_result(result, msg)
        unless result.nil?
          Chef::Log.debug("result: #{result.status} msg: #{msg}")
          new_resource.updated_by_last_action(true) if result.status == 200
          (result.status == 200)
        end
      end

      def verify_attribute(attribute_sym, verify_result_status = true, &fix_the_attribute)
        Chef::Log.info("verify #{resource_str}.#{attribute_sym}")
        fix_the_attribute ||= lambda {}

        current_value = @current_resource.send(attribute_sym)
        new_value = new_resource.send(attribute_sym)
        Chef::Log.info("#{resource_str}.#{attribute_sym} cur: #{current_value.inspect} new: #{new_value.inspect}")

        converge_if(current_value != new_value, "update '#{resource_str}.#{attribute_sym}' from '#{current_value}' to '#{new_value}'") do
          Chef::Log.info('converging')
          result = fix_the_attribute.call
          verify_result(result, "'#{resource_str}.#{attribute_sym}' (#{fix_the_attribute})") if verify_result_status
        end
      end
    end
  end
end
