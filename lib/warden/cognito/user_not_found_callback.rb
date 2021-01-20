module Warden
  module Cognito
    class UserNotFoundCallback
      include Cognito::Import['after_local_user_not_found']

      class << self
        def call(cognito_user, pool_identifier)
          new.call(cognito_user, pool_identifier)
        end
      end

      def call(cognito_user, pool_identifier)
        after_local_user_not_found&.call(cognito_user, pool_identifier)
      end
    end
  end
end
