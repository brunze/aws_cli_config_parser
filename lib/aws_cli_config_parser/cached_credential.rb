# frozen_string_literal: true

require 'json'
require 'date'

class AwsCliConfigParser::CachedCredential

  def initialize assumed_role, expiration_date, configuration
    @assumed_role = assumed_role or raise TypeError
    @expiration_date = expiration_date.to_time
    @configuration = configuration.to_hash
  end

  attr_reader :assumed_role, :expiration_date, :configuration

  def self.from_io io, parse_json: JSON.method(:parse), parse_date: DateTime.method(:parse)
    json = parse_json[io.read]

    assumed_role = json.dig('AssumedRoleUser', 'Arn') or return nil
    assumed_role = assumed_role.match(%r|arn:aws:sts:\w*:(\d{12}):assumed-role/(.+?)/?\w*/?$|)&.captures or return nil

    expiration_date = json.dig('Credentials', 'Expiration') or return nil
    expiration_date = parse_date[expiration_date]

    new(
      assumed_role,
      expiration_date,
      'aws_access_key_id'     => json.dig('Credentials', 'AccessKeyId'),
      'aws_secret_access_key' => json.dig('Credentials', 'SecretAccessKey'),
      'aws_session_token'     => json.dig('Credentials', 'SessionToken'),
    )
  end

  def expired? now: lambda{ Time.now.utc }
    @expiration_date <= now.call
  end

end