Redis.current = Redis.new(
  :host     => Sources::Api::ClowderConfig.instance["inMemoryDbHostname"],
  :port     => Sources::Api::ClowderConfig.instance["inMemoryDbPort"],
  :password => Sources::Api::ClowderConfig.instance["inMemoryDbPassword"]
)
