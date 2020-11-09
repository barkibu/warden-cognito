require 'aws-sdk-cognitoidentityprovider'

module Warden
  module Cognito
    class TokenAuthenticatableStrategie < Warden::Strategies::Base
      METHOD = 'Bearer'.freeze
      ISSUER = "https://cognito-idp.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USER_POOL_ID']}".freeze
      JWK_KEYS_URL = "#{ISSUER}/.well-known/jwks.json".freeze

      KB_UUID_ATTRIBUTE = 'custom:kb_uuid'.freeze

      def jwks
        # Rails.cache.fetch(JWK_KEYS_URL, expires_in: 1.hour) do
          JSON.parse(HTTP.get(JWK_KEYS_URL).body.to_s).deep_symbolize_keys
        # end
      end

      def valid?
        decoded_token.present?
      rescue ::JWT::ExpiredSignature
        true
      rescue StandardError
        false
      end

      def authenticate!
        # success! User.find(decoded_token.first[KB_UUID_ATTRIBUTE])
      rescue ::JWT::ExpiredSignature
        fail!(:token_expired)
      rescue ActiveRecord::RecordNotFound
        # success! User.create!(user_attributes)
      rescue StandardError
        fail(:unknown_error)
      end

      private

      def decoded_token
        @decoded_token ||= ::JWT.decode(token, nil, true, iss: ISSUER, verify_iss: true,
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

      # def user_attributes
      #   full_phone_number = decoded_token.first['phone_number']
      #   pn = Phoner::Phone.parse(full_phone_number)
      #   {
      #     phone_number: pn.format('%a%n'),
      #     phone_number_prefix: pn.format('+%c')
      #   }
      # end
    end
  end
end
