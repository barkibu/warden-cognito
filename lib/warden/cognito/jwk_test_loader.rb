module Warden
  module Cognito
    class JwkTestLoader < JwkLoader
      attr_reader :jwk

      def initialize(jwk)
        super()
        @jwk = jwk
      end

      def jwt_issuer
        'locally_generated_test_token_issuer'
      end

      def call(_options = {})
        { keys: [jwk.export] }
      end
    end
  end
end
