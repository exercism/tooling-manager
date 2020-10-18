# Tooling Manager

![Tests](https://github.com/exercism/tooling-manager/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/6000a7e8b72f65176c00/maintainability)](https://codeclimate.com/github/exercism/tooling-manager/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6000a7e8b72f65176c00/test_coverage)](https://codeclimate.com/github/exercism/tooling-manager/test_coverage)

An service responsible for deploying and managing Exercism's tooling.

## Server Setup

Each tooling server should have the following tags:

- `tooling-test-runners`
- `tooling-analyzers`
- `tooling-representers`

Each should have a value of a language group.
Language groups are stored in DynamoDB.

The language group is prefixed with the type when looked up.

For example, specifying the tag: `tooling-test-runners: "all"`, will lookup the `test-runners-all` group in DynamoDB.
