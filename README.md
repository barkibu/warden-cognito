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

Add to  your initializers the following:
```ruby
 Warden::Cognito.configure do |config|
    config.user_repository = User
    config.identifying_attribute = 'sub'
    config.after_local_user_not_found = ->(cognito_user) { User.create(username: cognito_user.username) }
    config.cache =  ActiveSupport::Cache::MemCacheStore.new
end
```

This gem will look for the following the env variables:
- **AWS_REGION**
- **AWS_COGNITO_USER_POOL_ID**
- **AWS_COGNITO_CLIENT_ID**

### User Repository

The user repository will be used to look for an entity to mark as authenticated, it must implement the following:
- `find_by_cognito_username` that should return the user identified by the given username or nil
- `find_by_cognito_attribute` that should return the user identified by the given Cognito User attribute (`config.identifying_attribute`) or nil

### `after_local_user_not_found` Callback

A callback triggered whenever the user correctly authenticated on Cognito but no local user exists (receives the full [cognito user](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html))

### Cache 
The cache used to store the AWS Json Web Keys as well as the mapping between local and remote identifiers.
Defaults to `ActiveSupport::Cache::NullStore`

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
