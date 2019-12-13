module SeedingConcern
  extend ActiveSupport::Concern

  module ClassMethods
    cattr_accessor :seed_key

    def seed
      seeds = YAML.load_file(Rails.root.join("db/seeds/#{table_name}.yml"))

      transaction do
        records = all.index_by(&seed_key)

        seeds.each do |key, attributes|
          if (r = records.delete(key))
            r.update!(attributes)
          else
            create!(attributes.merge(seed_key => key))
          end
        end

        records.values.map(&:destroy)
      end
    end
  end
end
