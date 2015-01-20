require 'spec_helper'
require 'fog'
require 'fog/aws/models/dns/zones'

describe Chef::Provider::GaloshesDnsZone do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when domain does not exist' do
    let(:resource) { Chef::Resource::GaloshesDnsZone.new('fake.domain.com.') }

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource).to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
        expect(updates).to include("create #{provider.resource_str}")
      end
    end
  end

  context 'when domain does exist' do
    let(:resource) { Chef::Resource::GaloshesDnsZone.new('existing.fake.domain.com.') }

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
        expect(provider.current_resource).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
        expect(updates).to include("create #{provider.resource_str}")
      end
    end
    describe '#action_update' do
      it 'is updated' do
        provider.action_update
      end
    end
  end
end
