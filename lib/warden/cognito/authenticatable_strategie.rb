require 'aws-sdk-cognitoidentityprovider'

module Warden
  module Cognito
    class AuthenticatableStrategie < Warden::Strategies::Base
      def valid?
        cognito_authenticable?
      end

      def authenticate!
        return unless cognito_authenticable?

        client = Aws::CognitoIdentityProvider::Client.new

        begin
          resp = client.initiate_auth(
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            auth_flow: 'USER_PASSWORD_AUTH',
            auth_parameters: {
              'USERNAME' => email,
              'PASSWORD' => password
            }
          )

          return fail(:unknow_cognito_response) unless resp

          # user = User.find_by(email: email)
          # unless user
          #   user = User.create(email: email, password: password, password_confirmation: password)
          #   return fail(:failed_to_create_user) unless user.valid?
          # end

          success!(user)
        rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException => e
          return fail(:invalid_login)
        rescue StandardError => e
          return fail(:unknow_cognito_response)
        end
      end

      def cognito_authenticable?
        params[scope].present? && password.present?
      end

      def email
        params[scope][:email]
      end

      def password
        params[scope][:password]
      end
    end
  end
end
