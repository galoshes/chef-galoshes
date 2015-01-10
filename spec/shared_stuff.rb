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

  let(:existing_zone_resource) { Chef::Resource::GaloshesDnsZone.new('existing.fake.domain.com.') }
  let(:existing_zone_provider) { Chef::Provider::GaloshesDnsZone.new(existing_zone_resource, run_context) }

  let(:existing_dns_record_resource) do
    record = Chef::Resource::GaloshesDnsRecord.new('existing_subdomain')
    record.zone(existing_zone_resource)
    record.type('A')
    record.ttl(60)
    record.value(['10.0.0.1'])
    record
  end
  let(:existing_dns_record_provider) { Chef::Provider::GaloshesDnsRecord.new(existing_dns_record_resource, run_context) }

  # defines security groups as follows
  # :existing_security_group_resource_#{name}
  # :existing_security_group_provider_#{name}
  def self.security_group(name)
    resource = Chef::Resource::GaloshesSecurityGroup.new("existing security group #{name}")
    resource.description("existing security group #{name}")
    resource.ip_permissions([])
    let("existing_security_group_resource_#{name}".to_sym) { resource }
    let("existing_security_group_provider_#{name}".to_sym) { Chef::Provider::GaloshesSecurityGroup.new(resource, run_context) }
  end
  security_group('a')
  security_group('b')
  security_group('c')

  let(:existing_load_balancer_resource) do
    resource = Chef::Resource::GaloshesLoadBalancer.new('existing load balancer')
    resource.security_groups([])
    resource.subnet_ids([])
    resource
  end
  let(:existing_load_balancer_provider) { Chef::Provider::GaloshesLoadBalancer.new(existing_load_balancer_resource, run_context) }

  before do
    existing_zone_provider.load_current_resource
    existing_zone_provider.action_create
    # puts "existing_zone_resource: #{existing_zone_resource.inspect}"

    existing_dns_record_provider.load_current_resource
    existing_dns_record_provider.action_create
    # puts "existing_dns_record_resource: #{existing_dns_record_resource.inspect}"

    existing_security_group_provider_a.load_current_resource
    existing_security_group_provider_a.action_create
    existing_security_group_provider_b.load_current_resource
    existing_security_group_provider_b.action_create
    existing_security_group_provider_c.load_current_resource
    existing_security_group_provider_c.action_create
    # puts "existing_sec_group_resource: #{existing_security_group_resource.inspect}"

    existing_load_balancer_provider.load_current_resource
    existing_load_balancer_provider.action_create
  end

  after do
    # in reverse order
    existing_load_balancer_provider.action_delete
    existing_security_group_provider_c.action_delete
    existing_security_group_provider_b.action_delete
    existing_security_group_provider_a.action_delete
    existing_dns_record_provider.action_delete
    existing_zone_provider.action_delete
  end
end
