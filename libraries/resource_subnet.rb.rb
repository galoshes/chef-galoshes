actions :create
default_action :create

attribute :cidr_block, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :availability_zone, :kind_of => [String]
attribute :vpc, :kind_of => [String]
attribute :vpc_id, :kind_of => [String]
attribute :tags, :kind_of => [Hash], :default => {}

def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesSubnet
end
