require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesLaunchConfiguration do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesLaunchConfiguration.new('new_launch_configuration')
      resource.image_id('ami-456')
      resource.instance_type('m1.small')
      resource.user_data('new user data')
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
      end
    end
  end

  context 'when resource does exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesLaunchConfiguration.new('existing launch configuration')
      resource.image_id('ami-456')
      resource.instance_type('m1.small')
      resource.user_data('new user data')
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
        expect(provider.current_resource.user_data).not_to eq(resource.user_data)
        expect(updates).to include("update '#{provider.resource_str}.user_data' from 'existing user data' to 'new user data'")
      end
    end
  end
end
