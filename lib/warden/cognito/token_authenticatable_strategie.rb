require 'aws-sdk-cognitoidentityprovider'
# rubocop:disable Style/SignalException

module Warden
  module Cognito
    class TokenAuthenticatableStrategie < Warden::Strategies::Base
      METHOD = 'Bearer'.freeze

      attr_reader :helper, :config

      def initialize(env, scope = nil)
        super
        @config = Cognito.config
        @helper = UserHelper
      end

      def jwks
        config.cache.fetch(JWK_KEYS_URL, expires_in: 1.hour) do
          JSON.parse(HTTP.get(jwk_url).body.to_s).deep_symbolize_keys
        end
      end

      def valid?
        decoded_token.present?
      rescue ::JWT::ExpiredSignature
        true
      rescue StandardError
        false
      end

      def authenticate!
        user = local_user || config.after_local_user_not_found&.call(cognito_user)
        fail!(:unknown_user) unless user.present?
        success!(user)
      rescue ::JWT::ExpiredSignature
        fail!(:token_expired)
      rescue StandardError
        fail(:unknown_error)
      end

      private

      def jwt_issuer
        "https://cognito-idp.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USER_POOL_ID']}"
      end

      def jwk_url
        "#{jwt_issuer}/.well-known/jwks.json"
      end

      def local_user
        helper.find_by_cognito_attribute(local_identifier)
      end

      def cognito_user_cache_key
        "COGNITO_LOCAL_IDENTIFIER_#{cognito_user_identifier}"
      end

      def cognito_user_identifier
        decoded_token.first['sub']
      end

      def local_identifier
        config.cache.fetch(cognito_user_cache_key) do
          user_attribute identifying_attribute
        end
      end

      def cognito_user
        @cognito_user ||= CognitoClient.fetch(token)
      end

      def user_attribute(attribute_name)
        cognito_user.user_attributes.detect do |attribute|
          attribute.name == attribute_name
        end&.value
      end

      def identifying_attribute
        config.identifying_attribute.to_s
      end

      def decoded_token
        @decoded_token ||= ::JWT.decode(token, nil, true, iss: jwt_issuer, verify_iss: true,
                                                          algorithms: ['RS256'], jwks: jwks)
      end

      def token
        @token ||= extract_token
      end

      def extract_token
        return nil unless authorization_header

        method, token = authorization_header.split
        method == METHOD ? token : nil
      end

      def authorization_header
        env['HTTP_AUTHORIZATION']
      end
    end
  end
end
# rubocop:enable Style/SignalException

Warden::Strategies.add(:cognito_jwt, Warden::Cognito::TokenAuthenticatableStrategie)
