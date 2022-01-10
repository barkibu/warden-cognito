require 'http'
require 'jwt'
require 'warden'
require 'dry/configurable'
require 'dry/auto_inject'

require 'active_support'
require 'active_support/core_ext'

module Warden
  module Cognito
    class CognitoError < StandardError; end

    extend Dry::Configurable

    def jwk_config_keys
      %i[key issuer]
    end

    def jwk_instance(value)
      attributes = value&.symbolize_keys&.slice(*jwk_config_keys) || {}
      Struct.new(*jwk_config_keys, keyword_init: true).new(attributes)
    end

    def user_pool_configuration_keys
      %i[identifier region pool_id client_id]
    end

    def user_pool_configurations(value)
      value.map do |key, conf|
        attributes = conf.symbolize_keys.slice(*user_pool_configuration_keys).merge(identifier: key)
        Struct.new(*user_pool_configuration_keys, keyword_init: true).new(attributes)
      end
    end

    module_function :jwk_config_keys, :jwk_instance, :user_pool_configuration_keys, :user_pool_configurations

    setting :user_repository
    setting :identifying_attribute, default: 'sub', constructor: ->(attr) { attr.to_s }
    setting :after_local_user_not_found
    setting :cache, default: ActiveSupport::Cache::NullStore.new

    setting :jwk, default: nil, constructor: ->(value) { jwk_instance(value) }

    setting :user_pools, default: [], constructor: ->(value) { user_pool_configurations(value) }

    Import = Dry::AutoInject(config)
  end
end

require 'warden/cognito/pool_related_iterator'
require 'warden/cognito/has_user_pool_identifier'
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
