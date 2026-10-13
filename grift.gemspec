# frozen_string_literal: true

require_relative 'lib/grift/version'

Gem::Specification.new do |spec|
  spec.name          = 'grift'
  spec.version       = Grift::VERSION
  spec.authors       = ['Clark Brown']
  spec.email         = ['clark@clark-brown.com']

  spec.summary       = 'Mocking and spying in MiniTest'
  spec.description   = "A gem for simple mocking and spying in Ruby's MiniTest framework."
  spec.homepage      = 'https://github.com/clarkedb/grift'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'documentation_uri' => spec.homepage.to_s,
    'homepage_uri' => spec.homepage.to_s,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => spec.homepage.to_s
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'CHANGELOG.md', 'LICENSE', 'README.md'].reject { |f| File.directory?(f) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
