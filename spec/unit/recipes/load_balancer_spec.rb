require 'spec_helper'
require 'fog'
Fog.mock!

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
      resource.security_groups([existing_security_group_resource_a.group_id])
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
        expect(provider.action_create).to eq([])
        expect(resource.dns_name).not_to eq(nil)
        expect(events).not_to eq(nil)
      end
    end
  end

  context 'when resource does exist' do
    let(:new_security_groups) { [
        existing_security_group_resource_b.group_id,
        existing_security_group_resource_c.group_id,
      ]}
    let(:resource) do
      resource = Chef::Resource::GaloshesLoadBalancer.new('existing load balancer')
      resource.security_groups(new_security_groups)
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
        expect(provider.action_create).to eq([])
        expect(provider.current_resource.security_groups).to eq(new_security_groups)
        expect(events).not_to eq(nil)
      end
    end
  end
end
