# frozen_string_literal: true

require_relative 'lib/aws_cli_config_parser/version'

Gem::Specification.new do |spec|
  spec.name        = 'aws_cli_config_parser'
  spec.version     = AwsCliConfigParser::VERSION
  spec.authors     = ['brunze']
  spec.homepage    = 'https://github.com/brunze/aws_cli_config_parser'
  spec.license     = 'MIT'
  spec.summary     = 'Parses profile settings from AWS CLI configuration files.'
  spec.description = <<~DESCRIPTION.strip
    Parses profile settings and secrets from AWS CLI configuration files,
    including temporary credentials cached by the CLI when using roles.
  DESCRIPTION

  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = spec.homepage + '/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['aws_cli_config_parser']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency 'example-gem', '~> 1.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
