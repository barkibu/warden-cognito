module Warden
  module Cognito
    class TokenDecoder
      attr_reader :jwk_loader, :token

      def initialize(token, pool_identifier = nil)
        @token = token
        @jwk_loader = find_loader(pool_identifier)
      end

      def validate!
        decoded_token.present?
      end

      def sub
        decoded_token.first['sub']
      end

      def decoded_token
        @decoded_token ||= ::JWT.decode(token, nil, true, iss: jwk_loader.jwt_issuer, verify_iss: true,
                                                          algorithms: ['RS256'], jwks: jwk_loader)
      end

      def cognito_user
        @cognito_user ||= CognitoClient.scope(pool_identifier).fetch(token)
      end

      def user_attribute(attribute_name)
        token_attribute(attribute_name).presence || cognito_user_attribute(attribute_name)
      end

      def pool_identifier
        jwk_loader.pool_identifier
      end

      private

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
