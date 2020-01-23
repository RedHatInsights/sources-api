module SeedingConcern
  extend ActiveSupport::Concern

  module ClassMethods
    cattr_accessor :seed_key

    def seed
      logger.info("Seeding #{name}...")
      seeds = YAML.load_file(Rails.root.join("db/seeds/#{table_name}.yml"))

      transaction do
        records = all.index_by(&seed_key)

        seeds.each do |key, attributes|
          if (r = records.delete(key))
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
