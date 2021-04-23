class AppMetaData < MetaData
  belongs_to :application_type

  def self.seed
    transaction do
      # Default to CI
      env = ENV['SOURCES_ENV'].presence || "ci"

      destroy_all

      metadata = YAML.safe_load(File.read("db/seeds/app_metadata.yml"))
      (metadata[env] || {}).each do |app, settings|
        apptype = ApplicationType.find_by(:name => app)

        settings.each do |key, value|
          apptype.app_meta_data.create!(
            :name    => key,
            :payload => value
          )
        end
      end
    end
  end
end
