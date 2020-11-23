module Warden
  module Cognito
    class LocalUserMapper
      include Cognito::Import['cache', 'identifying_attribute']

      def call(token_decoder)
        helper.find_by_cognito_attribute local_identifier(token_decoder)
      end

      private

      def local_identifier(token_decoder)
        cache_key = "COGNITO_LOCAL_IDENTIFIER_#{token_decoder.sub}"
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
