require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesVpc do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesVpc.new('new vpc')
      resource.dhcp_options_id(existing_dhcp_options.id)
      resource.cidr_block('10.0.0.0/16')
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource.id).to eq('new vpc')
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
      end
    end
  end

  context 'when resource does exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesVpc.new('existing vpc')
      resource.dhcp_options_id(existing_dhcp_options.id)
      resource.cidr_block('10.1.1.1/24')
      resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        # expect(provider.exists).to eq(true)
        expect(provider.current_resource).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
      end
    end
  end
end
