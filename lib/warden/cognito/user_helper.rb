module Warden
  module Cognito
    module UserHelper
      class << self
        def find_by_cognito_username(username)
          user_repository.find_by_cognito_username(username)
        end

        def find_by_cognito_attribute(arg)
          user_repository.find_by_cognito_attribute(arg)
        end

        private

        def user_repository
          Cognito.config.user_repository
        end
      end

      module ByCredentials
        def self.after_user_local_not_found(full_cognito_user)
          Cognito.config.after_local_user_by_credentials_not_found&.call(full_cognito_user)
        end
      end

      module ByToken
        def self.after_user_local_not_found(decoded_token)
          Cognito.config.after_local_user_by_token_not_found&.call(decoded_token)
        end
      end
    end
  end
end
