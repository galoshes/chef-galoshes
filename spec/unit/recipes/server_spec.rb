require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesServer do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesServer.new('fake_subdomain')
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource.id).to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
        expect(provider.exists).to eq(true)
      end
    end
  end

  context 'when resource does exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesServer.new('existing_server')
      resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        # expect(provider.exists).to eq(true)
        # expect(provider.current_resource).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
      end
    end
    describe '#action_update' do
      it 'is created' do
        provider.action_update
      end
    end
  end
end
