# frozen_string_literal: true

class AwsCliConfigParser::Profile

  def initialize name, configuration
    @name = name.to_str ; raise ArgumentError if @name.empty?
    @configuration = configuration
  end

  attr_reader :name, :configuration

  def role
    @configuration['role_arn'].to_s.match(%r|arn:aws:iam:\w*:(\d{12}):role/(.+?)/?$|)&.captures
  end

  def merge! other
    raise TypeError unless other.is_a?(self.class)

    @configuration.merge!(other.configuration)

    self
  end

  def merge_credential! credential
    @configuration.merge!(credential.configuration)
  end

  def get key
    @configuration[key]
  end

  def to_h
    @configuration.to_h
  end

end