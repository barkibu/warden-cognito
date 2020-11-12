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
    end
  end
end
