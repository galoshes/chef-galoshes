if node['platform_family'] == 'debian'
  xml = package 'libxml2-dev' do
    action :nothing
  end
  xml.run_action(:install)

  xslt = package 'libxslt1-dev' do
    action :nothing
  end
  xslt.run_action(:install)
elsif node['platform_family'] == 'rhel'
  xml = package 'libxml2-devel' do
    action :nothing
  end
  xml.run_action(:install)

  xslt = package 'libxslt-devel' do
    action :nothing
  end
  xslt.run_action(:install)
end

nokogiri = chef_gem 'nokogiri' do

  if node['platform'] == 'mac_os_x'
    version '>= 1.6.1'
  else
    version '= 1.6.1'
  end

end

if Gem::Specification.find_all_by_name('nokogiri').size == 0
  nokogiri.run_action(:install)
end

fog = chef_gem 'fog' do
  version '1.25.0'
end
fog.run_action(:install)
