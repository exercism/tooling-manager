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
      `curl http://169.254.169.254/latest/meta-data/instance-id`
    end

    memoize
    def region
      `curl http://169.254.169.254/latest/meta-data/placement/region`
    end
  end
end
