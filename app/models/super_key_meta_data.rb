class SuperKeyMetaData < MetaData
  belongs_to :application_type
  belongs_to :source_type

  default_scope { order(:step) }

  # required for the order of operations
  validates :step, :presence => true
  validates :name,
            :inclusion => {:in      => ["s3", "role", "policy", "bind_role", "cost_report", "lighthouse"],
                           :message => "%{value} is not a supported superkey operation"},
            :presence  => true

  def self.seed
    transaction do
      destroy_all

      YAML.safe_load(File.read("db/seeds/superkey_metadata.yml"))
          .deep_symbolize_keys
          .each do |app, settings|
        apptype = ApplicationType.find_by(:name => app)

        settings[:steps].each do |step|
          sourcetype = SourceType.find_by(:name => step[:source_type_name])

          create!(
            :application_type => apptype,
            :source_type      => sourcetype,
            :step             => step[:step],
            :name             => step[:name],
            :payload          => step[:payload],
            :substitutions    => step[:substitutions]
          )
        end
      end
    end
  end
end
