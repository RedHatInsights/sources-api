class AsyncDeleteJob < ApplicationJob
  queue_as :default

  def perform(instance, headers)
    Sidekiq.logger.info("Destroying #{instance.class} #{instance.id}...")

    Insights::API::Common::Request.with_request(:original_url => "noop", :headers => headers) do
      instance.destroy!
    end
  end
end
