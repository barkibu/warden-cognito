require 'jwt'
require 'warden'
require 'dry/configurable'
require 'dry/auto_inject'

require 'active_support'
require 'active_support/core_ext'

require 'warden/cognito/subject_decoder'
require 'warden/cognito/jwk_loader'

module Warden
  module Cognito
    extend Dry::Configurable

    setting :user_repository
    setting :identifying_attribute, 'sub'
    setting :after_local_user_not_found
    setting :cache, ActiveSupport::Cache::NullStore.new
    setting :jwk_loader, Warden::Cognito::JwkLoader.new
    setting :subject_decoder, Warden::Cognito::SubjectDecoder
    Import = Dry::AutoInject(config)
  end
end

require 'warden/cognito/version'
require 'warden/cognito/authenticatable_strategy'
require 'warden/cognito/token_authenticatable_strategy'
require 'warden/cognito/user_helper'
require 'warden/cognito/cognito_client'

require 'warden/cognito/test_helpers'
require 'warden/cognito/jwk_test_loader'
require 'warden/cognito/in_memory_subject_decoder'
