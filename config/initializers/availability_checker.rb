# Instantiate the Source Availability Checker Singleton
Rails.application.config.after_initialize do
  if defined?(::Rails::Server)
    checker_config = {
      :available   => {
        :check_frequency => 30.seconds
      },
      :unavailable => {
        :check_frequency => 10.seconds
      }
    }

    SourceAvailabilityChecker.instance(checker_config)
    puts "Source Availability Checker started ..."
  end
end
