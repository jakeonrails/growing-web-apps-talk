class Registry

  def self.redis
    @redis ||= Redis.new(ENV['REDIS_URL'] || "redis://localhost:6379")
  end

  def self.cache
    @cache ||= Rails.cache
  end

  def self.logger
    @logger ||= Rails.logger
  end

  def exception_tracker
    @exception_tracker ||= begin
      if Rails.env.production?
        NewRelic::ExceptionTracker.new
      else
        NullTracker.new
    end
  end

  private

  class NullTracker
    def notify(e, options);end
  end

end

redis = Registry.redis
