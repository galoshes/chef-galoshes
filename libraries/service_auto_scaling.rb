module Galoshes
  module AutoscalingService
    def service
      Fog::AWS::AutoScaling.new(:aws_access_key_id => aws_access_key_id, :aws_secret_access_key => aws_secret_access_key, :region => region)
    end
  end
end
