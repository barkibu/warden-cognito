module Warden
  module Cognito
    class TestHelpers
      class << self
        def setup_for_test
          Warden::Cognito.configure do |config|
            config.jwk_loader = Warden::Cognito::JwkTestLoader.new(JWT::JWK.new(OpenSSL::PKey::RSA.new(2048)))
            config.subject_decoder = Warden::Cognito::InMemorySubjectDecoder
          end
        end

        def auth_headers(headers, user)
          payload = { sub: user.cognito_identifier, iss: jwt_issuer }
          token_headers = { kid: jwk.kid }

          token = JWT.encode(payload, jwk.keypair, 'RS256', token_headers)
          headers['HTTP_AUTHORIZATION'] = "Bearer #{token}"

          InMemorySubjectDecoder.register_user(user, token)
          headers
        end

        def jwk
          config.jwk_loader.jwk
        end

        def jwt_issuer
          config.jwk_loader.jwt_issuer
        end

        private

        def cache
          config.cache
        end

        def config
          Warden::Cognito.config
        end
      end
    end
  end
end
