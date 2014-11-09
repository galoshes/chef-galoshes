
fog = chef_gem 'fog' do
  action :install
  version '1.24.0'
end
fog.run_action(:install)
