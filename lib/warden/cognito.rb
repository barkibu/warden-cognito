require 'jwt'
require 'warden'
require 'dry/configurable'
require 'dry/auto_inject'

require 'active_support'
require 'active_support/core_ext'

module Warden
  module Cognito
    extend Dry::Configurable

    setting :user_repository
    setting :identifying_attribute, 'sub'
    setting :after_local_user_by_credentials_not_found
    setting :after_local_user_by_token_not_found

    Import = Dry::AutoInject(config)
  end
end

require 'warden/cognito/version'
require 'warden/cognito/authenticatable_strategie'
require 'warden/cognito/token_authenticatable_strategie'
require 'warden/cognito/user_helper'
