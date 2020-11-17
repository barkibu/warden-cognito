module Warden
  module Cognito
    class JwkLoader
      def jwt_issuer
        "https://cognito-idp.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USER_POOL_ID']}"
      end

      def call(options)
        config.cache.clear(jwk_url) if options[:invalidate]

        config.cache.fetch(jwk_url, expires_in: 1.hour) do
          JSON.parse(HTTP.get(jwk_url).body.to_s).deep_symbolize_keys
        end
      end

      private

      def jwk_url
        "#{jwt_issuer}/.well-known/jwks.json"
      end

      def config
        Warden::Cognito.config
      end
    end
  end
end
