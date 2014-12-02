zone = galoshes_dns_zone 'fake.domain.com.' do
  aws_access_key_id 'access_key'
  aws_secret_access_key 'secret_key'
  action :create
end
