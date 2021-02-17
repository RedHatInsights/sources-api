module SeedingConcern
  extend ActiveSupport::Concern

  module ClassMethods
    cattr_accessor :seed_key

    def seed
      logger.info("Seeding #{name}...")
      seeds = YAML.load_file(Rails.root.join("db/seeds/#{table_name}.yml"))
      excluded_types = ENV.fetch("#{to_s.upcase}_SKIP_LIST", "").split(",")

      transaction do
        records = all.index_by(&seed_key)

        seeds.each do |key, attributes|
          if excluded_types.include?(key)
            records.delete(key)
            logger.info("Skipping #{key}")
          elsif (r = records.delete(key))
            logger.info("Updating #{key}")
            r.update!(attributes)
          else
            logger.info("Creating #{key}")
            create!(attributes.merge(seed_key => key))
          end
        end

        records.each_key { |key| logger.info("Deleting #{key}") }
        records.values.map(&:destroy)
      end
      logger.info("Seeding #{name}...Complete")
    end
  end
end
