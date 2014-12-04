require 'spec_helper'

describe 'galoshes::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04').converge(described_recipe) }

  it 'installs the correct packages' do
    expect(chef_run).to install_chef_gem('nokogiri').at_compile_time
    expect(chef_run).to install_chef_gem('fog').at_compile_time
  end
end
