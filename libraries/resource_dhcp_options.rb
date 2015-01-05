require 'chef/resource/lwrp_base'

class Chef::Resource::GaloshesDhcpOptions < Chef::Resource::LWRPBase
  self.resource_name = :galoshes_dhcp_options

  actions :create
  default_action :create

  attribute :id, :kind_of => [String, NilClass], :default => nil
  attribute :configuration_set, :kind_of => [Hash]
  attribute :tags, :kind_of => Hash, :default => {}
end
