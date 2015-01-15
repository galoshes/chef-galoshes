module Galoshes
  module ElbService
    def service
      Fog::AWS::ELB.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    end
  end
end
