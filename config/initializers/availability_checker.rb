# Instantiate the Source Availability Checker Singleton
Rails.application.config.after_initialize do
  if defined?(::Rails::Server)
    SourceAvailabilityChecker.instance
    puts "Source Availability Checker started ..."
  end
end
