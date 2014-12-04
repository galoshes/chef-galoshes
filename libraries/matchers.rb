if defined?(ChefSpec)
  def create_galoshes_dns_record(dns_record)
    ChefSpec::Matchers::ResourceMatcher.new(:galoshes_dns_record, :create, dns_record)
  end

  def create_galoshes_dns_zone(dns_zone)
    ChefSpec::Matchers::ResourceMatcher.new(:galoshes_dns_zone, :create, dns_zone)
  end
end
