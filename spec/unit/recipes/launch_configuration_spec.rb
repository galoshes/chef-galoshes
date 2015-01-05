require 'spec_helper'
require 'fog'
Fog.mock!

describe Chef::Provider::GaloshesLaunchConfiguration do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  let(:resource) { Chef::Resource::GaloshesLaunchConfiguration.new('fake_subdomain') }

  before do
    provider.new_resource = resource
  end

  context 'when resource does not exist' do
    before do
      provider.load_current_resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource.created_at).to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        # expect(provider.action_create).to eq([])
        # expect(events).not_to eq(nil)
      end
    end
  end

  context 'when resource does exist' do
    before do
      # @service = Fog::DNS.new(:provider => 'AWS', :aws_access_key_id => 'fake_access_key', :aws_secret_access_key => 'fake_secret_key')
      # @service.zones.create(:domain => 'fake.domain.com.')
      # log.debug("service.zones: #{@service.zones}")
      provider.load_current_resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        # expect(provider.exists).to eq(true)
        # expect(provider.current_resource).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        # expect(provider.action_create).to eq(nil)
        # expect(events).not_to eq(nil)
      end
    end
  end
end
