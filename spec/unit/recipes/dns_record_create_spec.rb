require 'spec_helper'
require 'fog'
Fog.mock!

describe Chef::Provider::GaloshesDnsRecord do
  include_context 'common stuff'
  subject(:provider) { described_class.new(resource, run_context) }

  let(:resource) { Chef::Resource::GaloshesDnsRecord.new('fake_subdomain') }

  before do
    provider.new_resource = resource
  end

  context 'when record does not exist' do
    before do
      provider.load_current_resource
    end

    describe '#load_current_resource' do
      it 'is empty' do
        expect(provider.exists).to eq(false)
        expect(provider.current_resource).to eq(nil)
      end
    end
  end
end
