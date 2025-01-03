# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

None

## [3.0.0](https://github.com/clarkedb/grift/releases/tag/v3.0.0) - 2024-12-26

### Breaking

- All mocks are now scoped to the current thread for thread-safety ([#256](https://github.com/clarkedb/grift/pull/256))
  - For parallelized test suites using processes this is not a breaking change
  - This fixes intermittent test failures sometimes seen when codebases have threads calling mocked methods

### Added

- Official support for Ruby 3.4 ([#257](https://github.com/clarkedb/grift/pull/257))
- Direct access to mock results/calls without calling `mock` ([#258](https://github.com/clarkedb/grift/pull/258))

## [2.2.0](https://github.com/clarkedb/grift/releases/tag/v2.2.0) - 2024-01-13

### Added

- Official support for Ruby 3.3 ([#203](https://github.com/clarkedb/grift/pull/203))

## [2.1.0](https://github.com/clarkedb/grift/releases/tag/v2.1.0) - 2022-12-27

### Added

- Official support for Ruby 3.2 ([#126](https://github.com/clarkedb/grift/pull/126))
- Support for finite/self-terminating mocking for more precision in testing where a method may get called multiple times
  - The Grift API now supports `mock_return_value_once`, `mock_return_value_n_times`, and `mock_return_values_in_order` ([#135](https://github.com/clarkedb/grift/pull/135))
  - The Grift API now supports `mock_implementation_once` and `mock_implementation_n_times` ([#136](https://github.com/clarkedb/grift/pull/136))

## [2.0.1](https://github.com/clarkedb/grift/releases/tag/v2.0.1) - 2022-03-27

### Fixed

- When spying on a method that takes a block, the block now gets forwarded to the original method ([#78](https://github.com/clarkedb/grift/pull/78))
- When mocking the implementation, if a block is not provided a `Grift::Error` is raised instead of a `LocalJumpError` ([#77](https://github.com/clarkedb/grift/pull/77))

## [2.0.0](https://github.com/clarkedb/grift/releases/tag/v2.0.0) - 2022-03-14

This version adds true keyword argument support for Ruby 3. See below for how to handle breaking changes.

### Changed

- Dropped support for Ruby 2.5 ([#69](https://github.com/clarkedb/grift/pull/69))
- Dropped support for Ruby 2.6 ([#72](https://github.com/clarkedb/grift/pull/72))
- To support keyword arguments, records of call arguments are no longer stored in simple arrays but in a custom Enumerable ([#72](https://github.com/clarkedb/grift/pull/72))
  - This changes the way that your tests will interact with mock calls
  - When before `calls` returned an array, it returns a `Grift::MockMethod::MockExecutions::MockArguments` object
  - Migrating to maintain previous behavior just requires appending `.args` to `calls[i]`

### Added

- Support for mocking private instance and class methods ([#68](https://github.com/clarkedb/grift/pull/68))
- Support for mocking methods that take positional and keyword arguments ([#72](https://github.com/clarkedb/grift/pull/72))

### Fixed

- When mocking protected methods, the method now remains protected while mocked and after unmocking ([#68](https://github.com/clarkedb/grift/pull/68))
- When mocking inherited methods, the method goes back to the ancestor's definition after unmocking ([#69](https://github.com/clarkedb/grift/pull/69))
- When mocking methods with keyword arugments in Ruby 3.x, no error is thrown ([#72](https://github.com/clarkedb/grift/pull/72))

## [1.1.0](https://github.com/clarkedb/grift/releases/tag/v1.1.0) - 2022-02-03

This version adds support for Ruby 3.1 and updates various dependencies.

### Added

- Support Ruby 3.1 ([#52](https://github.com/clarkedb/grift/pull/52))

## [1.0.2](https://github.com/clarkedb/grift/releases/tag/v1.0.2) - 2021-11-11

This version fixes a bug that prevented the mocking of methods defined by a class's super class.

### Fixed

- Allow mocks of inherited methods ([#34](https://github.com/clarkedb/grift/pull/34))

## [1.0.1](https://github.com/clarkedb/grift/releases/tag/v1.0.1) - 2021-11-10

This version fixes a bug that prevented most mocking features in Grift from functioning as expected.

### Fixed

- Uses relative path for yaml config files ([#28](https://github.com/clarkedb/grift/pull/28))

## [1.0.0](https://github.com/clarkedb/grift/releases/tag/v1.0.0) - 2021-11-06

The first major version of Grift! 100% documentation and 100% code coverage.

### Added

- Spying on method ([#9](https://github.com/clarkedb/grift/pull/9))
- Mocking method return values ([#9](https://github.com/clarkedb/grift/pull/9))
- Mocking method implementation ([#13](https://github.com/clarkedb/grift/pull/13))
- Restricted methods that cannot be mocked ([#20](https://github.com/clarkedb/grift/pull/20))
- MiniTest Plugin to use hooks and clean up after tests ([#17](https://github.com/clarkedb/grift/pull/17))
- Documentation! ([#23](https://github.com/clarkedb/grift/pull/23))

## [0.1.0](https://github.com/clarkedb/grift/releases/tag/v0.1.0) - 2021-10-12

The initial version of Grift. This was never intended for use and should be considered **deprecated**.
