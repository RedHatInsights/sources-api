class AsyncDeleteJob < ApplicationJob
  queue_as :default

  def perform(instance, headers)
    Sidekiq.logger.info("Destroying #{instance.class} #{instance.id}...")

    Sources::Api::Request.with_request(:original_url => "noop", :headers => headers) do
      instance.destroy!
    end
  end
end
