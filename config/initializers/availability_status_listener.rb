require 'sources/api/clowder_config'

# Be sure to restart your server when you modify this file.

# we ony want the AvailabilityStatusListener to start for the api pod, NOT the sidekiq pod.
sidekiq_pod = Rails.env.production? && ENV['HOSTNAME'].match?(/sidekiq/)

unless defined?(::Rails::Console) || sidekiq_pod
  queue_host = Sources::Api::ClowderConfig.instance['kafkaHost']
  queue_port = Sources::Api::ClowderConfig.instance['kafkaPort']

  availability_status_listener = AvailabilityStatusListener.new(:host => queue_host, :port => queue_port)
  availability_status_listener.run
end
