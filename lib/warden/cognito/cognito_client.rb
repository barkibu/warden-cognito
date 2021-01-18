module Warden
  module Cognito
    class UnknownPoolIdentifier < CognitoError; end

    class CognitoClient
      include Cognito::Import['user_pools']
      attr_reader :user_pool

      # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html
      def fetch(access_token)
        client.get_user(access_token: access_token)
      end

      def initiate_auth(email, password)
        client.initiate_auth(
          client_id: user_pool.client_id,
          auth_flow: 'USER_PASSWORD_AUTH',
          auth_parameters: {
            'USERNAME' => email,
            'PASSWORD' => password
          }
        )
      end

      def user_pool=(pool_identifier)
        @user_pool = user_pools.detect(->{user_pools.first}) { |pool| pool.identifier == pool_identifier }
      end

      def pool_identifier
        user_pool.identifier
      end

      private

      def client
        Aws::CognitoIdentityProvider::Client.new
      end

      class << self
        def scope(pool_identifier)
          new.tap do |client|
             client.user_pool = pool_identifier
          end
        end
      end
    end
  end
end
