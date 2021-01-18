module Warden
  module Cognito
    module HasUserPoolIdentifier
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          attr_reader :user_pool
        end
      end

      def user_pool=(pool_identifier)
        @user_pool = user_pools.detect(-> { user_pools.first }) { |pool| pool.identifier == pool_identifier }
      end

      def pool_identifier
        user_pool.identifier
      end

      module ClassMethods
        def pool_iterator
          PoolRelatedIterator.new do |pool|
            new.tap do |pool_related|
              pool_related.user_pool = pool.identifier
            end
          end
        end

        def default_pool
          new.tap do |pool_related|
            pool_related.user_pool = Warden::Cognito.config.user_pools.first.identifier
          end
        end
      end
    end
  end
end
