require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesLoadBalancer do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesLoadBalancer.new('new load balancer')
      resource.security_groups([existing_security_group_a.group_id])
      resource.subnet_ids([])
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource.created_at).to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
        expect(resource.dns_name).not_to eq(nil)
        expect(updates).to include("create #{provider.resource_str}")
      end
    end
  end

  context 'when resource does exist' do
    let(:new_security_groups) do
      [
        existing_security_group_b.group_id,
        existing_security_group_c.group_id,
      ]
    end
    let(:resource) do
      resource = Chef::Resource::GaloshesLoadBalancer.new('existing load balancer')
      resource.security_groups(new_security_groups)
      resource.subnet_ids([])
      resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
        expect(provider.current_resource.created_at).not_to eq(nil)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
        expect(provider.current_resource.security_groups).to eq(new_security_groups)
        expect(updates).to include("create #{provider.resource_str}")
      end
    end
  end
end
