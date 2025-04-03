module Warden
  module Cognito
    class RefreshableTokenDecoder
      attr_reader :jwk_loader, :token, :refresh_token, :cookie_setter

      def initialize(token, refresh_token, cookie_setter, pool_identifier = nil)
        @token = token
        @refresh_token = refresh_token
        @cookie_setter = cookie_setter
        @jwk_loader = find_loader(pool_identifier)
      end

      def validate!
        decoded_token.present?
      end

      def sub
        decoded_token.first['sub']
      end

      def decoded_token
        @decoded_token ||= decode_token
      rescue ::JWT::ExpiredSignature
        try_refresh
      end

      def cognito_user
        @cognito_user ||= cognito_client.fetch(token)
      end

      def user_attribute(attribute_name)
        token_attribute(attribute_name).presence || cognito_user_attribute(attribute_name)
      end

      def pool_identifier
        jwk_loader.pool_identifier
      end

      private

      def cognito_client
        @cognito_client ||= CognitoClient.scope(pool_identifier)
      end

      def try_refresh
        raise ::JWT::ExpiredSignature unless refresh_token

        username = ::JWT.decode(token, nil, false).first['username']

        access_token = cognito_client.exchange_token(refresh_token, username)
                                     .authentication_result
                                     .access_token

        cookie_setter.call('AccessToken', access_token)
        @token = access_token
        @decoded_token = decode_token
      rescue Aws::CognitoIdentityProvider::Errors::ExpiredCodeException
        raise ::JWT::ExpiredSignature
      end

      def decode_token
        ::JWT.decode(
          token,
          nil,
          true,
          iss: jwk_loader.jwt_issuer,
          verify_iss: true,
          algorithms: ['RS256'], jwks: jwk_loader
        )
      end

      def token_attribute(attribute_name)
        decoded_token.first[attribute_name] if decoded_token.first.key? attribute_name
      end

      def cognito_user_attribute(attribute_name)
        cognito_user.user_attributes.detect do |attribute|
          attribute.name == attribute_name
        end&.value
      end

      def find_loader(pool_identifier)
        if pool_identifier.present?
          return JwkLoader.new.tap do |loader|
            loader.user_pool = pool_identifier
          end
        end
        JwkLoader.pool_iterator.detect(JwkLoader.invalid_issuer_error) do |loader|
          loader.issued? token
        end
      end
    end
  end
end
