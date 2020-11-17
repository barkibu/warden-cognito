module Warden
  module Cognito
    class InMemorySubjectDecoder < SubjectDecoder
      @in_memory_users ||= {}

      def self.register_user(user, token)
        @in_memory_users[token] = user
      end

      def to_user!
        user = @in_memory_users[token]

        raise LocalUserNotFound, cognito_user unless user.present?

        user
      end
    end
  end
end
