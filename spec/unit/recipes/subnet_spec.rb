require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesSubnet do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesSubnet.new('new subnet')
      resource.subnet_id('subnet-new12356')
      resource.vpc_id(existing_vpc.id)
      resource.cidr_block('10.0.0.0/24')
      resource.tag_set('foo' => 'bar')
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource.vpc_id).to eq(nil)
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
      resource = Chef::Resource::GaloshesSubnet.new('existing subnet')
      resource.subnet_id(existing_subnet.subnet_id)
      resource.vpc_id(existing_vpc.id)
      resource.cidr_block('10.0.99.0/24')
      resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
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
