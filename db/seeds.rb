# seeding is handled on the Go side now.
if ENV['SKIP_SEEDING'] == "true"
  Rails.logger.warn "Skipping seeding due to ENV"
  exit 0
end

ApplicationType.seed
SourceType.seed
SuperKeyMetaData.seed
AppMetaData.seed
