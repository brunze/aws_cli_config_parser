require 'aws_cli_config_parser/refined/strings'

class AwsCliConfigParser::CLI::Arguments
  using AwsCliConfigParser::Refined::Strings

  attr_accessor :profile_name, :parameter_name, :aws_directory, :fallback_value

  def validated!
    raise TypeError, "profile name is required (use -p, --profile)" if profile_name.nil?   || profile_name.blank?
    raise TypeError, "parameter name is required (use -k, --key)"   if parameter_name.nil? || parameter_name.blank?
    self
  end

end