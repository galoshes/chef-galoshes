require 'spec_helper'
require 'fog'
Fog.mock!

describe Chef::Provider::GaloshesSecurityGroup do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesSecurityGroup.new('new security group')
      resource.description('new security group')
      resource.ip_permissions([])
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource).to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        expect(provider.action_create).to eq([])
        expect(events).not_to eq(nil)
        expect(resource.group_id).not_to eq(nil)
      end
    end
  end

  context 'when resource does exist' do
    let(:resource) { Chef::Resource::GaloshesSecurityGroup.new('existing security group') }

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
        expect(provider.current_resource).not_to eq(nil)
        expect(provider.current_resource.group_id).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        expect(provider.action_create).to eq(nil)
        expect(events).not_to eq(nil)
      end
    end
  end
end
