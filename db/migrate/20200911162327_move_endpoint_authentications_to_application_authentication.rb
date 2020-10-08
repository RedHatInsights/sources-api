class MoveEndpointAuthenticationsToApplicationAuthentication < ActiveRecord::Migration[5.2]
  def up
    [cost, subscription_watch].each do |type|
      # Skip the migration if there is no data to migrate.
      next if type.nil?

      ActiveRecord::Base.transaction do
        Application.where(:application_type_id => type.id).each do |app|
          source = app.source
          authentications = source.endpoints.flat_map(&:authentications)

          authentications.each do |auth|
            auth.update!(:resource => app)

            ApplicationAuthentication.find_or_create_by(
              :authentication_id => auth.id,
              :application_id    => app.id,
              :tenant            => source.tenant
            )
          end

          source.endpoints.map(&:delete)
        end
      end
    end
  end

  def down
    [cost, subscription_watch].each do |type|
      next if type.nil?

      ActiveRecord::Base.transaction do
        Application.where(:application_type_id => type.id).each do |app|
          source = app.source
          authentications = source.applications.flat_map(&:authentications)

          authentications.map(&:application_authentications).each(&:delete)

          endpoint = source.endpoints.find_or_create_by(:tenant => source.tenant, :default => true)
          authentications.each { |auth| auth.update!(:resource => endpoint) }
        end
      end
    end
  end

  private

  def cost
    @cost ||= ApplicationType.find_by(:name => "/insights/platform/cost-management")
  end

  def subscription_watch
    @subscription_watch ||= ApplicationType.find_by(:name => "/insights/platform/cloud-meter")
  end
end
