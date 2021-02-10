require 'sources/api/clowder_config'

# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = Sources::Api::ClowderConfig.instance['kafkaHost']
  queue_port = Sources::Api::ClowderConfig.instance['kafkaPort']

  availability_status_listener = AvailabilityStatusListener.new(:host => queue_host, :port => queue_port)
  availability_status_listener.run
end
