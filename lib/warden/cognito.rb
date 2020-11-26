require 'jwt'
require 'warden'
require 'dry/configurable'
require 'dry/auto_inject'

require 'active_support'
require 'active_support/core_ext'

module Warden
  module Cognito
    extend Dry::Configurable

    def jwk_config_keys
      %i[key issuer]
    end

    def jwk_instance(value)
      attributes = value&.symbolize_keys&.slice(*jwk_config_keys) || {}
      Struct.new(*jwk_config_keys, keyword_init: true).new(attributes)
    end

    module_function :jwk_config_keys, :jwk_instance

    setting :user_repository
    setting(:identifying_attribute, 'sub', &:to_s)
    setting :after_local_user_not_found
    setting :cache, ActiveSupport::Cache::NullStore.new

    setting(:jwk, nil) { |value| jwk_instance(value) }

    Import = Dry::AutoInject(config)
  end
end

require 'warden/cognito/jwk_loader'
require 'warden/cognito/version'
require 'warden/cognito/user_not_found_callback'
require 'warden/cognito/local_user_mapper'
require 'warden/cognito/authenticatable_strategy'
require 'warden/cognito/token_authenticatable_strategy'
require 'warden/cognito/token_decoder'
require 'warden/cognito/user_helper'
require 'warden/cognito/cognito_client'
require 'warden/cognito/test_helpers'
