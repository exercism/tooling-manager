# Tooling Manager

![Tests](https://github.com/exercism/tooling-manager/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/6000a7e8b72f65176c00/maintainability)](https://codeclimate.com/github/exercism/tooling-manager/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6000a7e8b72f65176c00/test_coverage)](https://codeclimate.com/github/exercism/tooling-manager/test_coverage)

An service responsible for deploying and managing Exercism's tooling.

It does the following:

- Gets the machines EC2 tags
- Looks for tags that list which languages should be used for each tool (e.g. `tooling-test-runners: all`)
- Creates a list of all the language/tool types
- For each:
  - Finds the production tag for that in ECR
  - Downloads the production image
  - Symlinks it.

All of that can be stepped through quite clearly in [`lib/tooling_manager/manager.rb`](lib/tooling_manager/manage.rb).

## Server Setup

Each tooling server should have the following tags:

- `tooling-test-runners`
- `tooling-analyzers`
- `tooling-representers`

Each should have a value of a language group.
Language groups are stored in DynamoDB.

The language group is prefixed with the type when looked up.

For example, specifying the tag: `tooling-test-runners: "all"`, will lookup the `test-runners-all` group in DynamoDB.
