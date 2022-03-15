# Grift

[![gem version](https://badge.fury.io/rb/grift.svg)](https://rubygems.org/gems/grift)
[![downloads](https://ruby-gem-downloads-badge.herokuapp.com/grift)](https://rubygems.org/gems/grift)
[![build](https://github.com/clarkedb/grift/actions/workflows/ci.yml/badge.svg)](https://github.com/clarkedb/grift/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/clarkedb/grift/branch/main/graph/badge.svg)](https://codecov.io/gh/clarkedb/grift)

Mocking and spying in Ruby's MiniTest framework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grift'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install grift
```

### MiniTest Plugin

We recommend using the plugin so that mocks are cleaned up after each test automatically. To enable the plugin, add the following lines of code to your `test_helper` file.

```ruby
class Minitest::Test
  include Grift::MinitestPlugin
end
```

Or for Ruby on Rails:

```ruby
class ActiveSupport::TestCase
  include Grift::MinitestPlugin
end
```

## Usage

For complete usage guide, see the [docs](https://clarkedb.github.io/grift/).

### Spy

To "mock" a method and spy on its call args and results without changing the behavior of the method:

```ruby
my_mock = Grift.spy_on(MyClass, :my_method)
```

### Mock

To mock a method and its return value:

```ruby
my_mock = Grift.mock(MyClass, :my_method, return_value)

my_spy = Grift.spy_on(MyClass, :my_method)
my_spy.mock_return_value(return_value)
```

To mock the implementation:

```ruby
my_spy = Grift.spy_on(MyClass, :my_method)
my_spy.mock_implementation do |arg1, arg2|
    x = do_something(arg1, arg2)
    do_something_else(x) # the last line will be returned
end
```

or for a method taking keyword arguments:

```ruby
my_spy = Grift.spy_on(MyClass, :my_method)
my_spy.mock_implementation do |arg1, arg2, **kwargs|
    x = do_something(arg1, arg2, kwargs[:arg3], kwargs[:arg4])
    do_something_else(x) # the last line will be returned
end
```

### Chaining

You can chain `mock_return_value` and `mock_implementation` after initializing the mock.

```ruby
my_mock = Grift.spy_on(MyClass, :my_method).mock_implementation do |*args, **kwargs|
    do_something(*args, **kwargs)
end
#=> Grift::MockMethod object is returned
```

### Results

To get the results and details of the calls, call `mock` on your mock method object.

```ruby
# get the number of times the mocked method has been called
my_mock.mock.count
#=> 2

# get args for each call to the method while mocked
my_mock.mock.calls[0].args
#=> ['first_arg1', 'second_arg1']

# get kwargs for each call to the method while mocked
my_mock.mock.calls[0].kwargs
#=> { first_arg1: 'value' }

# get results (return value) for each call to the method while mocked
my_mock.mock.results
#=> ['result1', 'result2']
```

## Requirements

Grift supports all Ruby versions >= 2.7 (including 3.1).

## Development

After forking the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

When developing, to install Grift whith your changes onto your local machine, run `bundle exec rake install` . For those with write access: to release a new version, update the version number in `version.rb` , and then run `bundle exec rake release` , which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Docs

The docs are generated using YARD. To build the docs, first `gem install yard` . Then run `yardoc` to build the new docs. This is always done before a release to update the docs that get published and made available with the gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at [clarkedb/grift](https://github.com/clarkedb/grift). Before submitting a pull request, see [CONTRIBUTING](.github/CONTRIBUTING.md).
