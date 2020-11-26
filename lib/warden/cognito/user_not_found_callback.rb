module Warden
  module Cognito
    class UserNotFoundCallback
      include Cognito::Import['after_local_user_not_found']

      class << self
        def call(cognito_user)
          new.call(cognito_user)
        end
      end

      def call(cognito_user)
        after_local_user_not_found&.call(cognito_user)
      end
    end
  end
end
