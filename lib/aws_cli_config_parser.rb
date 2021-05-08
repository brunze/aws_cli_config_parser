# frozen_string_literal: true

module AwsCliConfigParser; end

require 'aws_cli_config_parser/version'
require 'aws_cli_config_parser/profiles'
require 'aws_cli_config_parser/cached_credential'
require 'pathname'

module AwsCliConfigParser
  using Refined::Arrays

  def self.parse(
    aws_directory: '~/.aws',
    config_file_name: 'config',
    credentials_file_name: 'credentials',
    cli_cache_directory: './cli/cache',
    cached_credential_file_name_pattern: /\A\h{40}\.json\z/,
    now: lambda{ Time.now.utc }
  )
    aws_directory = Pathname(aws_directory).expand_path.realpath

    config_files = [
      aws_directory.join(config_file_name),
      aws_directory.join(credentials_file_name),
    ]
    .select{ |path| path.file? && path.readable_real? }

    cli_cache_directory = aws_directory.join(cli_cache_directory)

    cached_credential_files = if cli_cache_directory.directory? && cli_cache_directory.readable_real?
      cli_cache_directory
        .each_child
        .select{ |path| path.basename.to_s.match(cached_credential_file_name_pattern) }
        .select{ |path| path.file? && path.readable_real? }
    else
      []
    end

    parse_files(
      configs: config_files,
      cached_credentials: cached_credential_files,
      now: now,
    )
  end

  def self.parse_files configs: [], cached_credentials: [], now: lambda{ Time.now.utc }
    configs
      .map(&Profiles.method(:from_io))
      .reduce(:merge!)
      &.merge_credentials!(
        cached_credentials
          .map(&CachedCredential.method(:from_io))
          .reject{ |credential| credential.expired?(now: now) }
      ) || []
  end

end
