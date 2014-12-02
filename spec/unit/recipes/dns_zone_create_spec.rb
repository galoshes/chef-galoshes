require 'spec_helper'
require 'fog'
Fog.mock!

describe 'galoshes::dns_zone_create' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['galoshes_dns_zone']).converge(described_recipe)
  end

  it 'creates the zone' do
    expect(chef_run).to create_galoshes_dns_zone('fake.domain.com.')
  end
end
