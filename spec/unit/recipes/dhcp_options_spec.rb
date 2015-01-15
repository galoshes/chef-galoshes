require 'spec_helper'
require 'fog'

describe Chef::Provider::GaloshesDhcpOptions do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  before do
    provider.new_resource = resource
    provider.load_current_resource
  end

  context 'when resource does not exist' do
    let(:resource) do
      resource = Chef::Resource::GaloshesDhcpOptions.new('fake_subdomain')
      resource.configuration_set('domain-name' => ['test-cloud01.tigertext.me'], 'domain-name-servers' => ['AmazonProvidedDNS'])
      resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        # expect(provider.exists).to eq(false)
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
      resource = Chef::Resource::GaloshesDhcpOptions.new('fake_subdomain')
      resource.configuration_set('domain-name' => ['test-cloud01.tigertext.me'], 'domain-name-servers' => ['AmazonProvidedDNS'])
      resource
    end

    describe '#load_current_resource' do
      it 'is populated' do
        expect(provider.exists).to eq(true)
      end
    end
    describe '#action_create' do
      it 'is created' do
        provider.action_create
      end
    end
  end
end
