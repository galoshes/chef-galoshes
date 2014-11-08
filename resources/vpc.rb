actions :create
default_action :create

def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesVpc
end

attribute :cidr_block, :kind_of => [String]
attribute :id, :kind_of => [String], :default => nil
attribute :dhcp_options, :kind_of => [String]
attribute :dhcp_options_id, :kind_of => [String, NilClass], :default => nil
attribute :tags, :kind_of => [Hash], :default => {}
attribute :enable_dns_support, :kind_of => [TrueClass, FalseClass], :default => true
attribute :enable_dns_hostnames, :kind_of => [TrueClass, FalseClass], :default => false
attribute :tenancy, :equal_to => ['default', 'dedicated'], :default => 'default'
