module Warden
  module Cognito
    class LocalUserMapper
      include Cognito::Import['cache', 'identifying_attribute']

      class << self
        def find(token_decoder)
          new.call(token_decoder)
        end

        def find_by_token(token)
          find(TokenDecoder.new(token, nil))
        end
      end

      def call(token_decoder)
        helper.find_by_cognito_attribute local_identifier(token_decoder), token_decoder.pool_identifier
      end

      private

      def local_identifier(token_decoder)
        cache_key = "COGNITO_POOL_#{token_decoder.pool_identifier}LOCAL_IDENTIFIER_#{token_decoder.sub}"
        cache.fetch(cache_key, skip_nil: true) do
          token_decoder.user_attribute(identifying_attribute)
        end
      end

      def helper
        UserHelper.new
      end
    end
  end
end
