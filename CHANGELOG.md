# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

* Dropped support for Ruby 2.5 and Ruby 2.6
* To support keyword arguments, records of call arguments are no longer stored in simple arrays but in a custom Enumerable
  + This changes the way that your tests will interact with mock calls
  + When before `calls` returned an array, it returns a `Grift::MockMethod::MockExecutions::MockArguments` object
  + Migrating to maintain previous behavior just requires appending `.args` to `calls`

### Added

* Support for mocking private instance and class methods
* Support for mocking methods that take positional and keyword arguments

### Fixed

* When mocking protected methods, the method now remains protected while mocked and after unmocking
* When mocking inherited methods, the method goes back to the ancestor's definition after unmocking

## [1.1.0](https://github.com/clarkedb/grift/releases/tag/v1.1.0) - 2022-02-03

This version adds support for Ruby 3.1 and updates various dependencies.

### Added

* Support Ruby 3.1

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
