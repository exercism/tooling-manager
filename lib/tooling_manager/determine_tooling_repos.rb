module ToolingManager
  class DetermineToolingRepos
    include Mandate

    initialize_with :tags

    def call
      tooling_for('test-runners') +
        tooling_for('analyzers') +
        tooling_for('representers')
    end

    def tooling_for(type)
      tool = type.to_s.gsub(/s$/, '')
      languages_for(type).map do |lang|
        "#{lang}-#{tool}"
      end
    end

    def languages_for(type)
      # Takes the type "test_runners" and looks up the
      # tooling-test-runners tag, then maps the result
      # to be prefixed 'test-runners'. e.g. if the value
      # is "all,interpolated", we get 'test-runners-all' and
      # 'test-runners-interpolated'
      groups = tags.fetch("tooling-#{type}", "").
        split(',').map { |group| "#{type}-#{group}" }

      # Cross-references the reference groups with the
      # requested keys, and gets the set of languages.
      groups_reference.slice(*groups).
        values.
        flatten.
        uniq
    end

    memoize
    def groups_reference
      client = Exercism.dynamodb_client

      # Get all the language_groups from dynamo
      resp = client.scan(
        table_name: Exercism.config.dynamodb_tooling_language_groups_table
      )
      items = resp.to_h[:items]
      items.each_with_object({}) do |item, h|
        h[item['group']] = item['languages'].split(',')
      end
    end

    def parse_tooling_tag(tooling)
      tags.fetch("tooling-#{tooling}", "").split(',')
    end
  end
end
