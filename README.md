# Warden::Cognito

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


Add to  your initializers the following:
```ruby
 Warden::Cognito.configure do |config|
    config.user_repository = User
    config.identifying_attribute = 'sub'
    config.after_local_user_by_credentials_not_found = ->(cognito_user) { User.create(username: cognito_user.username) }
    config.after_local_user_by_token_not_found = ->(decoded_token) { User.create(cognito_id: decoded_token['sub']) }
end
```

### User Repository

The user repository will be used to look for an entity to mark as authenticated, it must implement the following:
- `find_by_cognito_username` that should return the user identified by the given username or nil
- `find_by_cognito_attribute` that should return the user identified by the given Cognito User attribute (`config.identifying_attribute`) or nil

### Callbacks

#### `after_local_user_by_credentials_not_found`

A callback triggered whenever the user correctly authenticated on Cognito but no local user exists (receives the full [cognito user](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html))

#### `after_local_user_by_token_not_found`

A callback triggered whenever the user has a valid Cognito JWT but no local user exists. It receives as param the decoded payload, for instance:

```json
{
  "sub": "54318465-/***/-50d9a32bb9",
  "aud": "5rbi/***/1ob58b",
  "email_verified": true,
  "event_id": "ff772ae4/***/4c59759d0f",
  "token_use": "id",
  "custom:foo": "bar",
  "auth_time": 1604052748,
  "iss": "https://cognito-idp.eu-west-1.amazonaws.com/eu-west-1_zpxXxXxX",
  "cognito:username": "54318465-b153-44e0-b834-0550d9a32bb9",
  "exp": 1604056348,
  "iat": 1604052748,
  "email": "jmj@barkibu.com"
}
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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/warden-cognito.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
