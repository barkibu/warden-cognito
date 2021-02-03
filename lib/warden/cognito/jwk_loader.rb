module Warden
  module Cognito
    class JwkLoader
      include Cognito::Import['cache', 'jwk', 'user_pools']
      include HasUserPoolIdentifier

      def jwt_issuer
        return "#{user_pool.identifier}-#{jwk.issuer}" if jwk.issuer.present?

        "https://cognito-idp.#{user_pool.region}.amazonaws.com/#{user_pool.pool_id}"
      end

      def issued?(token)
        ::JWT.decode(token, nil, false).first['iss'] == jwt_issuer
      rescue StandardError
        false
      end

      def call(options)
        return { keys: [jwk.key.export] } if jwk.key.present?

        cache.delete(jwk_url) if options[:invalidate]

        cache.fetch(jwk_url, expires_in: 1.hour) do
          JSON.parse(HTTP.get(jwk_url).body.to_s).deep_symbolize_keys
        end
      end

      private

      def jwk_url
        "#{jwt_issuer}/.well-known/jwks.json"
      end
    end
  end
end
