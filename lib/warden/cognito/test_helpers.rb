require 'rspec'

module Warden
  module Cognito
    class TestHelpers
      class EnvironmentError < StandardError; end

      @jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048))

      class << self
        attr_reader :jwk

        def setup
          Warden::Cognito.config.jwk = { key: jwk, issuer: local_issuer }
        end

        def auth_headers(headers, user)
          headers.merge(Authorization: "Bearer #{generate_token(user)}")
        end

        def local_issuer
          'local_issuer'
        end

        private

        def generate_token(user)
          payload = { sub: user.object_id,
                      "#{identifying_attribute}": user.cognito_id,
                      iss: local_issuer }
          headers = { kid: jwk.kid }
          JWT.encode(payload, jwk.keypair, 'RS256', headers)
        end

        def identifying_attribute
          Warden::Cognito.config.identifying_attribute
        end
      end
    end
  end
end
