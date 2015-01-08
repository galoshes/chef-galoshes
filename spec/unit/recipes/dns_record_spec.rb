require 'spec_helper'
require 'fog'
Fog.mock!

describe Chef::Provider::GaloshesDnsRecord do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  let(:resource) do
    record = Chef::Resource::GaloshesDnsRecord.new('fake_subdomain')
    record.zone(existing_zone_resource)
    record.type('A')
    record.ttl(60)
    record.value(['10.0.0.1'])

    record
  end

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
        expect(provider.action_create).to eq([])
        expect(events).not_to eq(nil)
      end
    end
  end

  context 'when resource does exist' do
    before do
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
