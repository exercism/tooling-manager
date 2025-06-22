module ToolingManager
  class ExtractMachineTags
    include Mandate

    memoize
    def call
      client = Aws::EC2::Client.new(region:)
      resp = client.describe_tags(
        {
          filters: [
            {
              name: "resource-id",
              values: [
                instance_id
              ]
            }
          ]
        }
      )

      resp[:tags].each_with_object({}) do |tag, hash|
        hash[tag[:key]] = tag[:value]
      end
    end

    memoize
    def instance_id
      `curl -s -H "X-aws-ec2-metadata-token: $(curl -s -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' http://169.254.169.254/latest/api/token)" http://169.254.169.254/latest/meta-data/instance-id` # rubocop:disable Layout/LineLength
    end

    memoize
    def region
      `curl -s -H "X-aws-ec2-metadata-token: $(curl -s -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' http://169.254.169.254/latest/api/token)" http://169.254.169.254/latest/meta-data/placement/region` # rubocop:disable Layout/LineLength
    end
  end
end
