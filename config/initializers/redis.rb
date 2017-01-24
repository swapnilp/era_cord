$redis = Redis.new(:host => ENV['REDIS_SERVER'], 
                       :port => ENV["REDIS_PORT"], db: 0)
