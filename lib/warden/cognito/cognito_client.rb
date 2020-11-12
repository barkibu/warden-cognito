module Warden
  module Cognito
    class CognitoClient
      class << self
        # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html
        def fetch(access_token)
          client.get_user(access_token: access_token)
        end

        def initiate_auth(email, password)
          client.initiate_auth(
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            auth_flow: 'USER_PASSWORD_AUTH',
            auth_parameters: {
              'USERNAME' => email,
              'PASSWORD' => password
            }
          )
        end

        private

        def client
          Aws::CognitoIdentityProvider::Client.new
        end
      end
    end
  end
end
