module Warden
  module Cognito
    class UserHelper
      include Cognito::Import['user_repository']

      def find_by_cognito_username(username, pool_identifier)
        user_repository.find_by_cognito_username(username, pool_identifier)
      end

      def find_by_cognito_attribute(arg, pool_identifier)
        user_repository.find_by_cognito_attribute(arg, pool_identifier)
      end
    end
  end
end
