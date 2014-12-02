zone = galoshes_dns_zone 'fake.domain.com.' do
  aws_access_key_id 'access_key'
  aws_secret_access_key 'secret_key'
end
zone.run_action(:create)

galoshes_dns_record 'fake-subdomain' do
  aws_access_key_id 'access_key'
  aws_secret_access_key 'secret_key'
  ttl 60
  zone lazy { zone }
  type 'A'
  value [ '10.0.0.1' ]
  action :create
end
