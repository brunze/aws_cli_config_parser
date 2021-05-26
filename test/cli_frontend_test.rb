# frozen_string_literal: true

require 'test_helper'
require 'pathname'
require 'open3'

describe 'AwsCliConfigParser::CLI' do

  EXECUTABLE_PATH    = Pathname(__dir__).join('../bin/aws_cli_config_parser').expand_path.to_s
  AWS_DIRECTORY_PATH = Pathname(__dir__).join('files').to_s

  def run_cli *args
    output, status = Open3.capture2e('bundle', 'exec', EXECUTABLE_PATH, *args)
    output.chop!
    [output, status]
  end

  it "extracts a single configuration value from the parsed AWS CLI configuration files" do
    options = %W(
      --profile default
      --key region
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'eu-west-1'

    options = %W(
      -p alice
      --key aws_access_key_id
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'AKIA1111000011110000'

    options = %W(
      -p alice
      -k aws_secret_access_key
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'SECRET1111000011110000111100001111000011'

    options = %W(
      -p alice
      -k region
      -d #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'eu-central-1'
  end

  it "errors out if the configuration parameter is not set" do
    options = %W(
      --profile default
      --key bogus
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    refute status.success?
  end

  it "errors out if the profile is not found" do
    options = %W(
      --profile bogus
      --key region
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    refute status.success?
  end

  it "allows the user to provide a fallback value in case the profile is missing or the parameter is not set" do
    options = %W(
      --profile default
      --key bogus
      --fallback FALLBACK
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'FALLBACK'

    options = %W(
      -p bogus
      -k region
      -f DEFAULT
      --directory #{AWS_DIRECTORY_PATH}
    )
    output, status = run_cli(*options)
    assert status.success?
    assert_equal output, 'DEFAULT'
  end

  it "prints help information" do
    output, status = run_cli(*%w(-h))
    assert status.success?
    assert output.include?('Usage:')

    output, status = run_cli(*%w(--help))
    assert status.success?
    assert output.include?('Usage:')
  end

  it "prints current version" do
    output, status = run_cli(*%w(-v))
    assert status.success?
    assert output.include?(AwsCliConfigParser::VERSION.to_s)

    output, status = run_cli(*%w(--version))
    assert status.success?
    assert output.include?(AwsCliConfigParser::VERSION.to_s)
  end

end