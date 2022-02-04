# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

N/A

## [1.1.0](https://github.com/clarkedb/grift/releases/tag/v1.1.0) - 2022-02-03

This version adds support for Ruby 3.1 and updates various dependencies.

### Added

* Support Ruby 3.1

### Updated

* Updates `minitest`
* Updates `minitest-reporters`
* Updates `rubocop`
* Updates `rubocop-minitest`
* Updates `rubocop-performance`

## [1.0.2](https://github.com/clarkedb/grift/releases/tag/v1.0.2) - 2021-11-11

This version fixes a bug that prevented the mocking of methods defined by a class's super class.

### Fixed

* Allow mocks of inherited methods

## [1.0.1](https://github.com/clarkedb/grift/releases/tag/v1.0.1) - 2021-11-10

This version fixes a bug that prevented most mocking features in Grift from functioning as expected.

### Fixed

* Uses relative path for yaml config files

### Updated

* Updates `rubocop-performance`
* Updates `rake`

## [1.0.0](https://github.com/clarkedb/grift/releases/tag/v1.0.0) - 2021-11-06

The first major version of Grift! 100% documentation and 100% code coverage.

### Added

* Spying on method
* Mocking method return values
* Mocking method implementation
* Restricted methods that cannot be mocked
* MiniTest Plugin to use hooks and clean up after tests
* Documentation!

## [0.1.0](https://github.com/clarkedb/grift/releases/tag/v0.1.0) - 2021-10-12

The initial version of Grift. This was never intended for use and should be considered **deprecated**.
