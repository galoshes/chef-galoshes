$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'spec_helper'
require 'fog'
require 'fog/aws/models/dns/zones'
Fog.mock!

describe Chef::Provider::GaloshesDnsZone do
  subject(:provider) { Chef::Provider::GaloshesDnsZone.new(new_resource, run_context) }
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

  let(:new_resource) { Chef::Resource::GaloshesDnsZone.new('fake.domain.com.') }

  before do
    provider.new_resource = new_resource
  end

  context 'domain does not exist' do
    before do
      provider.load_current_resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource).to eq(nil)
      end
    end
  end

  context 'domain does exist' do
    before do
      @service = Fog::DNS.new(:provider => 'AWS', :aws_access_key_id => 'fake_access_key', :aws_secret_access_key => 'fake_secret_key')
      @service.zones.create(:domain => 'fake.domain.com.')
      log.debug("service.zones: #{@service.zones}")
      provider.load_current_resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
        expect(provider.current_resource).not_to eq(nil)
      end
    end
  end
end
