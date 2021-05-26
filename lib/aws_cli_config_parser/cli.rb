# frozen_string_literal: true

require 'aws_cli_config_parser'

class AwsCliConfigParser::CLI; end

require 'aws_cli_config_parser/cli/arguments'
require 'optparse'

class AwsCliConfigParser::CLI

  def dispatch argv
    arguments = parse_arguments(argv).validated!
    fallback  = arguments.fallback_value

    profiles = AwsCliConfigParser.parse(
      aws_directory: arguments.aws_directory || '~/.aws',
    )

    if (profile = profiles.get(arguments.profile_name)).nil? && fallback.nil?
      $stderr.puts "could not find profile `#{arguments.profile_name}`"
      exit 1
    elsif (value = profile&.get(arguments.parameter_name)).nil? && fallback.nil?
      $stderr.puts "could not find a value for the parameter `#{arguments.parameter_name}`"
      exit 1
    else
      puts value || fallback
      exit 0
    end
  end

  private

  def parse_arguments argv
    Arguments.new.tap do |arguments|
      OptionParser.new do |parser|
        parser.banner = <<~BANNER
          Extracts a configuration value from AWS CLI configuration files.

            Usage: aws_cli_config_parser -p PROFILE -k KEY [-f FALLBACK] [-d AWS_DIRECTORY]

        BANNER

        parser.on('-p', '--profile=PROFILE', 'Profile from which to extract the configuration value.') do |profile|
          arguments.profile_name = profile
        end
        parser.on('-k', '--key=KEY', 'Name of the configuration parameter to extract.') do |key|
          arguments.parameter_name = key
        end
        parser.on('-f', '--fallback=VALUE', 'A default value to be returned in case a configuration value cannot be found.') do |value|
          arguments.fallback_value = value
        end
        parser.on('-d', '--directory=PATH', 'Path to the AWS CLI configuration directory (default: `~/.aws`).') do |path|
          arguments.aws_directory = path
        end

        parser.on_tail('-h', '--help', 'Prints this message.') do
          puts parser.help
          exit
        end
        parser.on_tail('-v', '--version', 'Prints the program version.') do
          puts AwsCliConfigParser::VERSION
          exit
        end
      end
      .parse!(argv)
    end
  end

end
