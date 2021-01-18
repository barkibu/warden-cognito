class PoolRelatedIterator
  include Enumerable

  attr_reader :factory

  def initialize(&factory)
    @factory = factory
  end

  def each(&block)
    Warden::Cognito.config.user_pools.each do |pool|
      block.call factory.call(pool)
    end
  end
end
