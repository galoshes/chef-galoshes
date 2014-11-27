module Galoshes
  module DeleteMixin
    def action_delete
      if @exists
        converge_by("delete #{resource_str}") do
          @current_resource.destroy
          @exists = false
          new_resource.updated_by_last_action(true)
        end
      end
    end
  end
end
