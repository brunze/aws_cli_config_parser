# AWS CLI Configuration Parser

This Ruby gem provides a tool to parse profile settings and secrets from AWS CLI configuration files, including the cached credentials from STS AssumeRole calls. This is often useful when using the AWS CLI with roles that require an MFA code. After authenticating successfully with an MFA code temporary session credentials are cached in your `~/.aws` folder. You'll often need to pass these temporary credentials to other tools such as Docker containers. This gem parses the files in your `~/.aws` folder and merges all information allowing you to retrieve any credential or setting.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_cli_config_parser'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aws_cli_config_parser


## Usage

With a file tree like this:

```
~/.aws/
├── cli
│   └── cache
│       ├── 1a2b3c4d5etc.json
├── config
└── credentials
```

**~/.aws/config**
```
[default]
region = eu-west-1

[profile admin]
role_arn = arn:aws:iam::222200002222:role/SomeRole
source_profile = default
role_session_name = session_name
region = eu-central-1
```

**~/.aws/credentials**
```
[default]
aws_access_key_id = AKID1111000011110000
aws_secret_access_key = SECRET1111000011110000111100001111000011
```

**~/.aws/cli/cache/1a2b3c4d5etc.json**
```
{
  "Credentials": {
    "AccessKeyId": "AKID2222000022220000",
    "SecretAccessKey": "SECRET2222000022220000222200002222000022",
    "SessionToken": "SESSIONTOKEN222200002222000022220000222200002222000022220000etc",
    "Expiration": "<some timestamp in the future>"
  },
  "AssumedRoleUser": {
    "AssumedRoleId": "ARLID2222000022220000:session_name",
    "Arn": "arn:aws:sts::222200002222:assumed-role/SomeRole/session_name"
  },
  ...
}
```

You can obtain any individual configuration value like this:

```ruby
profiles = AwsCliConfigParser.parse
# => #<AwsCliConfigParser::Profiles:0x000055b0526261e8>

default = profiles.get('default')
# => #<AwsCliConfigParser::Profile:0x000055b052654ea8>

default.get('region')
# => "eu-west-1"
default.get('aws_access_key_id')
# => "AKID1111000011110000"
default.get('aws_secret_access_key')
# => "SECRET1111000011110000111100001111000011"

admin = profiles.get('admin')
# => #<AwsCliConfigParser::Profile:0x000055b052644b98>

admin.get('region')
# => "eu-central-1"
admin.get('role_arn')
# => "arn:aws:iam::222200002222:role/SomeRole"
admin.get('aws_access_key_id')
# => "AKID2222000022220000"
admin.get('aws_secret_access_key')
# => "SECRET2222000022220000222200002222000022"
admin.get('aws_session_token')
# => "SESSIONTOKEN222200002222000022220000222200002222000022220000etc"
```

Or if you prefer using hashes:

```ruby
AwsCliConfigParser.parse.to_h == {
  'default' => {
    'region'                => 'eu-west-1',
    'aws_access_key_id'     => 'AKID1111000011110000',
    'aws_secret_access_key' => 'SECRET1111000011110000111100001111000011'
  },
  'admin' => {
    'region'                => 'eu-central-1',
    'role_arn'              => 'arn:aws:iam::222200002222:role/SomeRole',
    'source_profile'        => 'default',
    'role_session_name'     => 'session_name',
    'aws_access_key_id'     => 'AKID2222000022220000',
    'aws_secret_access_key' => 'SECRET2222000022220000222200002222000022',
    'aws_session_token'     => 'SESSIONTOKEN222200002222000022220000222200002222000022220000etc',
  }
}
# => true
```

If you have your AWS CLI configuration directory somewhere other than the default you can tell the parser where to look for it:

```ruby
AwsCliConfigParser.parse(aws_directory: '/somewhere/else/.my-aws-folder')
# => ...
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
