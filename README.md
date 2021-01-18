# Warden::Cognito

[![Build Status](https://travis-ci.com/barkibu/warden-cognito.svg?branch=master)](https://travis-ci.com/barkibu/warden-cognito)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/warden/cognito`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'warden-cognito'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warden-cognito

## Usage

Configure how the gem maps Cognito users to local ones adding to your initializers the following:
```ruby
 Warden::Cognito.configure do |config|
    config.user_repository = User
    config.identifying_attribute = 'sub'
    config.after_local_user_not_found = ->(cognito_user, pool_identifier) { User.create(username: cognito_user.username) }
    config.cache =  ActiveSupport::Cache::MemCacheStore.new
    config.user_pools = { default: {region: 'AWS_REGION', pool_id: 'AWS Cognito UserPool Id', client_id: 'AWS Cognito Client Id'} }
end
```

### With Devise

You can know protects endpoints by settings the available strategies in the Warden section of your Device's configuration:
```ruby
  # config/initializers/devise.rb
  # 
  # /***/
  config.warden do |manager|
    manager.default_strategies(scope: :user).unshift :cognito_auth
    manager.default_strategies(scope: :user).unshift :cognito_jwt
    # /***/
  end
```

### User Repository

The user repository will be used to look for an entity to mark as authenticated, it must implement the following:
- `find_by_cognito_username` that should return the user identified by the given username or nil (receives as second param the pool_identifier)
- `find_by_cognito_attribute` that should return the user identified by the given Cognito User attribute (`config.identifying_attribute`) or nil (receives as second param the pool_identifier)

### User Model

The user model must expose a message `cognito_id` that returns the `identifying_attribute` for the given user.

### `after_local_user_not_found` Callback

A callback triggered whenever the user correctly authenticated on Cognito but no local user exists (receives the full [cognito user](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html), and the pool_identifier as second parameter).

### Cache 
The cache used to store the AWS Json Web Keys as well as the mapping between local and remote identifiers.
Defaults to `ActiveSupport::Cache::NullStore`

### Testing

The TestHelpers module is here to help testing code using this gem to validate tokens and authenticate users:

Create a module and make sure it is loaded as part of the support files of your rspec configuration:

```ruby
module Helpers
  module JWT
    def self.included(base)
      base.class_eval do
        Warden::Cognito::TestHelpers.setup
      end
    end

    def auth_headers_for_user(user, headers = {})
      Warden::Cognito::TestHelpers.auth_headers(headers, user)
    end

    def jwt_for_user(user)
      auth_headers_for_user(user)[:Authorization].split[1]
    end
  end
end
```

Include this module in the relevant test types:
```ruby
RSpec.configure do |config|
  # /***/
  config.include Helpers::JWT, type: :request
end
```

You can now generate tokens for your users in your tests, for instance:
```ruby
let(:user) { create(:user) } # Your users needs to be available through the UserRepository you defined
let(:headers) { auth_headers_for_user(user) }
let(:token) { jwt_for_user(user) }
```

### API

This gem also exposes classes that you can use to validate tokens and/or fetch a user from a given token:

```ruby
token = 'The token a user passed along in a request'
token_decoder = TokenDecoder.new(token, nil) # Pass nil as pool_identifier to loop over all the configured pools and automatically bind the right one [Based on the issuer]

# Is the token valid ?
token_decoder.validate!

# What's in this token ?
token_decoder.decoded_token

# What's the phone_number attribute of the user identified by this token ?
token_decoder.user_attribute('phone_number')

# Who is the local user associated with this token
user = LocalUserMapper.find(token_decoder)
# or 
user = LocalUserMapper.find_by_token(token)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### With Docker

There are docker and docker-compose files configured to create a development environment for this gem. So, if you use Docker you only need to run:

`docker-compose up -d`

An then, for example:

`docker-compose exec app rspec`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/barkibu/warden-cognito.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
