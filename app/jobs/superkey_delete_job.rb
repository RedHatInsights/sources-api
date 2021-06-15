class SuperkeyDeleteJob < ApplicationJob
  queue_as :default

  def perform(source, headers)
    if source.super_key_credential.nil?
      Sidekiq.logger.warn("No superkey credential for source #{source.id}, destroying inline.")
      ::AsyncDeleteJob.perform_now(source, headers)
      return
    end

    Sources::Api::Request.with_request(:original_url => "noop", :headers => headers) do
      source.applications.each do |app|
        sk = Sources::SuperKey.new(
          :provider    => source.source_type.name,
          :source_id   => source.id,
          :application => app
        )

        app.discard
        sk.teardown

        # store a key in redis that expires in 30 seconds, that way we don't
        # double-enqueue a delete job for the superkey resources.
        Redis.current.setex("application_#{app.id}_delete_queued", 30, true)
      end

      # pause the source, then queue a destroy job 15 seconds from now.
      ::AsyncDeleteJob.set(:wait => 15.seconds).perform_later(source, headers)
    end
  end
end
