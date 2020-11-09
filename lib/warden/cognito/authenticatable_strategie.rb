require 'aws-sdk-cognitoidentityprovider'
# rubocop:disable Style/SignalException

module Warden
  module Cognito
    class AuthenticatableStrategie < Warden::Strategies::Base
      attr_reader :helper

      def initialize(env, scope = nil)
        super
        @helper = UserHelper
      end

      def valid?
        cognito_authenticable?
      end

      def authenticate!
        initiate_auth_response = client.initiate_auth(
          client_id: ENV['AWS_COGNITO_CLIENT_ID'],
          auth_flow: 'USER_PASSWORD_AUTH',
          auth_parameters: {
            'USERNAME' => email,
            'PASSWORD' => password
          }
        )

        return fail(:unknow_cognito_response) unless initiate_auth_response

        user = local_user || after_user_local_not_found(initiate_auth_response.authentication_result)

        fail!(:unknown_user) unless user.present?
        success!(user)
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        fail(:invalid_login)
      rescue StandardError
        fail(:unknow_cognito_response)
      end

      private

      def client
        client = Aws::CognitoIdentityProvider::Client.new
      end

      def local_user
        helper.find_by_cognito_username(email)
      end

      def after_user_local_not_found(authentication_result)
        # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CognitoIdentityProvider/Types/GetUserResponse.html
        user_response = client.get_user(access_token: authentication_result.access_token)
        helper::ByCredentials.after_user_local_not_found(user_response)
      end

      def cognito_authenticable?
        params[scope.to_s].present? && password.present?
      end

      def email
        auth_params[:email]
      end

      def password
        auth_params[:password]
      end

      def auth_params
        params[scope.to_s].symbolize_keys.slice(:password, :email)
      end
    end
  end
end
# rubocop:enable Style/SignalException

Warden::Strategies.add(:cognito_auth, Warden::Cognito::AuthenticatableStrategie)
