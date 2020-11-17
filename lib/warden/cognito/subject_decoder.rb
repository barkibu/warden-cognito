module Warden
  module Cognito
    class SubjectDecoder
      class LocalUserNotFound < StandardError
        attr_reader :cognito_user

        def initialize(cognito_user)
          super('User not found locally')
          @cognito_user = cognito_user
        end
      end

      attr_reader :sub, :helper, :config, :token

      def initialize(sub, token)
        @sub = sub
        @token = token
        @helper = UserHelper
        @config = Warden::Cognito.config
      end

      def to_user!
        user = helper.find_by_cognito_attribute(local_identifier)
        raise LocalUserNotFound, cognito_user unless user

        user
      end

      private

      def cognito_user
        @cognito_user ||= CognitoClient.fetch(token)
      end

      def local_identifier
        config.cache.fetch(cognito_user_cache_key, skip_nil: true) do
          user_attribute identifying_attribute
        end
      end

      def user_attribute(attribute_name)
        cognito_user.user_attributes.detect do |attribute|
          attribute.name == attribute_name
        end&.value
      end

      def cognito_user_cache_key
        "COGNITO_LOCAL_IDENTIFIER_#{sub}"
      end

      def identifying_attribute
        config.identifying_attribute.to_s
      end
    end
  end
end
