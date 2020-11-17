require 'aws-sdk-cognitoidentityprovider'
# rubocop:disable Style/SignalException

module Warden
  module Cognito
    class TokenAuthenticatableStrategy < Warden::Strategies::Base
      METHOD = 'Bearer'.freeze

      attr_reader :config

      def initialize(env, scope = nil)
        super
        @config = Cognito.config
      end

      def valid?
        decoded_token.present?
      rescue ::JWT::ExpiredSignature
        true
      rescue StandardError
        false
      end

      def authenticate!
        user = local_user
        fail!(:unknown_user) unless user.present?
        success!(user)
      rescue ::JWT::ExpiredSignature
        fail!(:token_expired)
      rescue StandardError
        fail(:unknown_error)
      end

      private

      def subject
        decoded_token.first['sub']
      end

      def local_user
        subject_decoder.to_user!
      rescue SubjectDecoder::LocalUserNotFound => e
        config.after_local_user_not_found&.call(e.cognito_user)
      end

      def subject_decoder
        config.subject_decoder.new(subject, token)
      end

      def decoded_token
        @decoded_token ||= ::JWT.decode(token, nil, true, iss: jwk_loader.jwt_issuer, verify_iss: true,
                                                          algorithms: ['RS256'], jwks: jwk_loader)
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

      def jwk_loader
        config.jwk_loader
      end
    end
  end
end
# rubocop:enable Style/SignalException

Warden::Strategies.add(:cognito_jwt, Warden::Cognito::TokenAuthenticatableStrategy)
