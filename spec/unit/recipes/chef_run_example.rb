require 'spec_helper'
require 'fog'

describe 'galoshes::dns_record_create' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(:step_into => %w(galoshes_dns_zone galoshes_dns_record)).converge(described_recipe)
  end

  it 'creates the record' do
    expect(chef_run).to create_galoshes_dns_record('fake-subdomain')
  end
end
