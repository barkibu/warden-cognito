module Warden
  module Cognito
    class TokenDecoder
      attr_reader :jwk_loader, :token

      def initialize(token)
        @token = token
        @jwk_loader = JwkLoader.new
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
        @cognito_user ||= CognitoClient.fetch(token)
      end

      def user_attribute(attribute_name)
        cognito_user.user_attributes.detect do |attribute|
          attribute.name == attribute_name
        end&.value
      end
    end
  end
end
