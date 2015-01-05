actions :create
default_action :create

attribute :id, :kind_of => [String, NilClass], :default => nil
attribute :configuration_set, :kind_of => [Hash]
attribute :tags, :kind_of => Hash, :default => {}

def initialize(*args)
  super
  @provider = Chef::Provider::GaloshesDhcpOptions
end
