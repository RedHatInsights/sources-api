# require 'app-common-ruby'
# require 'singleton'
#
# class ClowderConfig
#   include Singleton
#
#   def self.instance
#     @instance ||= {}.tap do |options|
#       if ENV["CLOWDER_ENABLED"].present?
#         config = LoadedConfig # TODO not an ideal name
#         options["webPorts"] = config.webPort
#         options["metricsPort"] = config.metricsPort
#         options["metricsPath"] = config.metricsPath
#         options["kafkaBrokers"] = [].tap do |brokers|
#           config.kafka.brokers.each do |broker|
#             brokers << "#{broker.hostname}:#{broker.port}"
#           end
#         end
#         options["kafkaTopics"] = [].tap do |topics|
#           config.kafka.topics.each do |topic|
#             topics << {topic.name.to_s => topic.requestedName.to_s}
#           end
#         end
#         options["logGroup"] = config.logging.cloudwatch.logGroup
#         options["awsRegion"] = config.logging.cloudwatch.region
#         options["awsAccessKeyId"] = config.logging.cloudwatch.accessKeyId
#         options["awsSecretAccessKey"] = config.logging.cloudwatch.secretAccessKey
#         options["databaseHostname"] = config.database.hostname
#         options["databasePort"] = config.database.port
#         options["databaseName"] = config.database.name
#         options["databaseUsername"] = config.database.username
#         options["databasePassword"] = config.database.password
#         options["QUEUE_HOST"] = options["kafkaBrokers"].first&.hostname # ??
#         options["QUEUE_PORT"] = options["kafkaBrokers"].first&.port # ??
#
#       else
#         options["webPorts"] = 3000
#         options["metricsPort"] = (ENV['METRICS_PORT'] || 9394).to_i
#         options["kafkaBrokers"] = ["#{ENV['QUEUE_HOST']}:#{ENV['QUEUE_PORT']}"]
#         options["logGroup"] = "platform-dev"
#         options["awsRegion"] = "us-east-1"
#         options["awsAccessKeyId"] = ENV['CW_AWS_ACCESS_KEY_ID']
#         options["awsSecretAccessKey"] = ENV['CW_AWS_SECRET_ACCESS_KEY']
#         options["databaseHostname"] = ENV['DATABASE_HOST']
#         options["databaseName"] = ENV['DATABASE_NAME']
#         options["databasePort"] = ENV['DATABASE_PORT']
#         options["databaseUsername"] = ENV['DATABASE_USER']
#         options["databasePassword"] = ENV['DATABASE_PASSWORD']
#         options["QUEUE_HOST"] = ENV["QUEUE_HOST"] || "localhost"
#         options["QUEUE_PORT"] = ENV["QUEUE_PORT"] || "9092"
#       end
#
#       options["APP_NAME"] = ENV['APP_NAME']
#       # options["PATH_PREFIX"] = "api"
#     end
#   end
# end
#
# # ManageIQ Message Client depends on these variables
# ENV["QUEUE_HOST"] = ClowderConfig.instance["QUEUE_HOST"]
# ENV["QUEUE_PORT"] = ClowderConfig.instance["QUEUE_PORT"]
#
# # ManageIQ Logger depends on these variables
# ENV['CW_AWS_ACCESS_KEY_ID'] = ClowderConfig.instance["awsAccessKeyId"]
# ENV['CW_AWS_SECRET_ACCESS_KEY'] = ClowderConfig.instance["awsSecretAccessKey"]