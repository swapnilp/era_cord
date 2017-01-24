class ApiRpmStore
 
  TIME_TO_EXPIRE = 1.minute # 1 min
 
  class << self
    attr_accessor :redis_client
 
    def init(config = {})
      self.redis_client = $redis #Redis.new(:url => "redis://#{config['host']}:#{config['port']}/#{config['database']}")
    end
 
    def incr(key)
      #val = redis_client.incr(key)
      val = $redis.incr(key)
      $redis.expire(key, TIME_TO_EXPIRE) if val == 1
      val
    end
 
    def threshold?(key, threshold_value = 0)
      self.incr(key) > threshold_value
    end
 
  end
 
end
