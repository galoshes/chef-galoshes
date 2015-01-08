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

  before do
    @service = Fog::DNS.new(:provider => 'AWS', :aws_access_key_id => 'fake_access_key', :aws_secret_access_key => 'fake_secret_key')
    @existing_zone = @service.zones.create(:domain => 'existing.fake.domain.com.')
    log.debug "existing_zone: #{@existing_zone}"
    existing_zone_provider.load_current_resource
    log.debug "existing_zone_resource: #{existing_zone_resource}"
  end

  after do
    @existing_zone.destroy
  end
end
