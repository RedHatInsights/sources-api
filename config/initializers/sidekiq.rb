redis_host = Sources::Api::ClowderConfig.instance["inMemoryDbHostname"]
redis_port = Sources::Api::ClowderConfig.instance["inMemoryDbPort"]
redis_password = Sources::Api::ClowderConfig.instance["inMemoryDbPassword"]

Sidekiq.configure_server do |config|
  config.redis = {
    :url      => "redis://#{redis_host}:#{redis_port}/0",
    :password => redis_password
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    :url      => "redis://#{redis_host}:#{redis_port}/0",
    :password => redis_password
  }
end
