module ToolingManager
  class RetrieveProductionRepoTag
    include Mandate

    # TODO: Change to production
    PRODUCTION_TAG = "production".freeze

    initialize_with :repo_name

    def call
      client = ExercismConfig::SetupECRClient.()

      resp = client.describe_images(
        repository_name: repo_name,
        image_ids: [
          {
            image_tag: PRODUCTION_TAG
          }
        ]
      )
      image = resp.image_details.first
      return nil unless image

      # Remove the "production" tag
      image[:image_tags].delete(PRODUCTION_TAG)

      # And return the next one (which might be nil)
      # making this a noop as if there was no tag
      image[:image_tags].first
    end
  end
end
