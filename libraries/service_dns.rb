module Galoshes
  module DnsService
    def service
      Fog::DNS::AWS.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key)
    end
  end
end
