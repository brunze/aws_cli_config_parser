# frozen_string_literal: true

require 'test_helper'
require 'pathname'

describe AwsCliConfigParser do

  let (:subject) { AwsCliConfigParser              }
  let (:dir)     { Pathname(__dir__).join('files') }

  it "has a version number" do
    refute_nil ::AwsCliConfigParser::VERSION
  end

  it "parses all files in the AWS CLI directory and merges all information" do
    profiles = subject.parse(aws_directory: dir, now: ->{ Time.new(2021, 4, 26, 11, 0, 0) })

    default = profiles.get('default')
    assert_equal default.get('region'), 'eu-west-1'

    alice = profiles.get('alice')
    assert_equal alice.get('region'), 'eu-central-1'
    assert_equal alice.get('aws_access_key_id'), 'AKIA1111000011110000'
    assert_equal alice.get('aws_secret_access_key'), 'SECRET1111000011110000111100001111000011'

    bob = profiles.get('bob')
    assert_equal bob.get('region'), 'eu-central-1'
    assert_equal bob.get('source_profile'), 'alice'
    assert_equal bob.get('role_arn'), 'arn:aws:iam::222200002222:role/SomeRole'
    assert_equal bob.get('role_session_name'), 'session_name'
    assert_equal bob.get('duration_seconds'), '43200'
    assert_equal bob.get('aws_access_key_id'), 'AKID2222000022220000'
    assert_equal bob.get('aws_secret_access_key'), 'SECRET2222000022220000222200002222000022'
    assert_equal bob.get('aws_session_token'), 'SESSIONTOKEN222200002222000022220000222200002222000022220000etc'

    carol = profiles.get('carol')
    assert_equal carol.get('region'), 'eu-central-1'
    assert_equal carol.get('source_profile'), 'alice'
    assert_equal carol.get('role_arn'), 'arn:aws:iam::333300003333:role/SomeOtherRole'
    assert_equal carol.get('role_session_name'), 'another_session_name'
    assert_equal carol.get('mfa_serial'), 'arn:aws:iam::111100001111:mfa/alice'

    assert_equal profiles.to_h, {
      'default' => {
        'region' => 'eu-west-1',
      },
      'alice' => {
        'region'                => 'eu-central-1',
        'aws_access_key_id'     => 'AKIA1111000011110000',
        'aws_secret_access_key' => 'SECRET1111000011110000111100001111000011',
      },
      'bob' => {
        'region'                => 'eu-central-1',
        'source_profile'        => 'alice',
        'role_arn'              => 'arn:aws:iam::222200002222:role/SomeRole',
        'role_session_name'     => 'session_name',
        'duration_seconds'      => '43200',
        'aws_access_key_id'     => 'AKID2222000022220000',
        'aws_secret_access_key' => 'SECRET2222000022220000222200002222000022',
        'aws_session_token'     => 'SESSIONTOKEN222200002222000022220000222200002222000022220000etc',
      },
      'carol' => {
        'region'            => 'eu-central-1',
        'source_profile'    => 'alice',
        'role_arn'          => 'arn:aws:iam::333300003333:role/SomeOtherRole',
        'role_session_name' => 'another_session_name',
        'mfa_serial'        => 'arn:aws:iam::111100001111:mfa/alice',
      },
    }
  end

  it "excludes any credentials that have expired" do
    profiles = subject.parse(aws_directory: dir, now: ->{ Time.new(2021, 4, 26, 11, 0, 0) })

    assert_nil profiles.get('carol').get('aws_access_key_id')
    assert_nil profiles.get('carol').get('aws_secret_access_key')
    assert_nil profiles.get('carol').get('aws_session_token')

    carol = profiles.to_h.fetch('carol')
    refute carol.has_key?('aws_access_key_id')
    refute carol.has_key?('aws_secret_access_key')
    refute carol.has_key?('aws_session_token')
  end

end