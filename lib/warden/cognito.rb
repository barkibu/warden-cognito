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
    setting :after_local_user_not_found
    setting :cache, ActiveSupport::Cache::NullStore.new

    Import = Dry::AutoInject(config)
  end
end

require 'warden/cognito/version'
require 'warden/cognito/authenticatable_strategy'
require 'warden/cognito/token_authenticatable_strategy'
require 'warden/cognito/user_helper'
require 'warden/cognito/cognito_client'
