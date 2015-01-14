shared_context 'common stuff' do
  let(:log) { Logger.new(STDOUT).tap { |l| l.level = Logger::INFO } }
  let(:node) do
    node = Chef::Node.new
    # node.automatic['platform'] = 'ubuntu'
    # node.automatic['platform_version'] = '12.04'
    node.normal['galoshes']['aws_access_key_id'] = 'fake_access_key'
    node.normal['galoshes']['aws_secret_access_key'] = 'fake_secret_key'
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }

  let(:existing_zone) do
    resource = Chef::Resource::GaloshesDnsZone.new('existing.fake.domain.com.')
    provider = Chef::Provider::GaloshesDnsZone.new(resource, run_context)
    provider.load_current_resource
    provider.action_create
    # puts "existing_zone: #{resource.inspect}"
    resource
  end

  let(:existing_dns_record) do
    resource = Chef::Resource::GaloshesDnsRecord.new('existing_subdomain')
    resource.zone(existing_zone)
    resource.type('A')
    resource.ttl(60)
    resource.value(['10.0.0.1'])
    provider = Chef::Provider::GaloshesDnsRecord.new(resource, run_context)
    provider.load_current_resource
    provider.action_create
    # puts "existing_dns_record: #{resource.inspect}"
    resource
  end

  # defines security groups as follows
  # :existing_security_group_#{name}
  def self.security_group(name)
    let("existing_security_group_#{name}".to_sym) do
      resource = Chef::Resource::GaloshesSecurityGroup.new("existing security group #{name}")
      resource.description("existing security group #{name}")
      resource.ip_permissions([])
      provider = Chef::Provider::GaloshesSecurityGroup.new(resource, run_context)
      provider.load_current_resource
      provider.action_create
      # puts "existing_sec_group: #{existing_security_group.inspect}"
      resource
    end
  end
  security_group('a')
  security_group('b')
  security_group('c')

  let(:existing_load_balancer) do
    resource = Chef::Resource::GaloshesLoadBalancer.new('existing load balancer')
    resource.security_groups([])
    resource.subnet_ids([])
    provider = Chef::Provider::GaloshesLoadBalancer.new(resource, run_context)
    provider.load_current_resource
    provider.action_create
    resource
  end

  before do
    Fog.mock!
    Fog::Mock.reset
  end
end
