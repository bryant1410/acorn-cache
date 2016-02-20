require 'acorn_cache/redis_cache'

class Rack::AcornCache
  module CacheReader
    def read(request_path)
      response = RedisCache.redis.get(request_path)
      return false unless response
      response_hash = JSON.parse(response)
      CachedResponse.new(response_hash)
    end
  end
end
