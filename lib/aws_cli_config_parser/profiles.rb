# frozen_string_literal: true

require 'aws_cli_config_parser/profile'
require 'aws_cli_config_parser/refined/arrays'

class AwsCliConfigParser::Profiles
  using ::AwsCliConfigParser::Refined::Arrays

  def initialize profiles
    @profiles = profiles.each.to_a or raise TypeError
  end

  def self.from_io io
    new(
      io.each_line.with_object([]) do |line, profiles|
        case line
        when /^ *\[(?:profile +)?(.+)\] *\n$/ then $1.strip! ;           ; profiles.push({ name: $1 })
        when /^ *(\w+) *= *(.+) *\n?$/        then $1.strip! ; $2.strip! ; profiles.last.store($1, $2)
        else next
        end
      end
      .map do |pairs|
        ::AwsCliConfigParser::Profile.new(pairs.delete(:name), pairs)
      end
    )
  end

  def merge! other
    raise TypeError unless other.is_a?(self.class)

    @profiles = [
      *@profiles,
      *other.instance_variable_get(:@profiles),
    ]
    .group_by(&:name)
    .map do |(_name, profiles)|
      profiles.reduce(:merge!)
    end

    self
  end

  def merge_credentials! credentials
    credentials = credentials.to_a.index_by(&:assumed_role)

    @profiles.each do |profile|
      profile.merge_credential!(credentials[profile.role]) if credentials.has_key?(profile.role)
    end

    self
  end

  def get name
    @profiles.find{ |profile| profile.name == name }
  end

  def to_h
    @profiles.map{ |profile| [profile.name, profile.to_h] }.to_h
  end

end