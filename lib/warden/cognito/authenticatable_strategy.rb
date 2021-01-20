require 'aws-sdk-cognitoidentityprovider'
# rubocop:disable Style/SignalException

module Warden
  module Cognito
    class AuthenticatableStrategy < Warden::Strategies::Base
      attr_reader :helper, :user_not_found_callback

      def initialize(env, scope = nil)
        super
        @user_not_found_callback = UserNotFoundCallback.new
        @helper = UserHelper.new
      end

      def valid?
        cognito_authenticable?
      end

      def authenticate!
        attempt = cognito_client.initiate_auth(email, password)

        return fail(:unknow_cognito_response) unless attempt

        user = local_user || trigger_callback(attempt.authentication_result)

        fail!(:unknown_user) unless user.present?
        success!(user)
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        fail!(:invalid_login)
      rescue StandardError
        fail(:unknow_cognito_response)
      end

      private

      def cognito_client
        CognitoClient.scope pool_identifier
      end

      def trigger_callback(authentication_result)
        cognito_user = cognito_client.fetch(authentication_result.access_token)
        user_not_found_callback.call(cognito_user, cognito_client.pool_identifier)
      end

      def local_user
        helper.find_by_cognito_username(email, cognito_client.pool_identifier)
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

      def pool_identifier
        auth_params[:pool_identifier]&.to_sym
      end

      def auth_params
        params[scope.to_s].symbolize_keys.slice(:password, :email, :pool_identifier)
      end
    end
  end
end
# rubocop:enable Style/SignalException

Warden::Strategies.add(:cognito_auth, Warden::Cognito::AuthenticatableStrategy)
