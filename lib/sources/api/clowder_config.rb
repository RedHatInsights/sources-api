require 'clowder-common-ruby'
require 'singleton'

module Sources
  module Api
    class ClowderConfig
      include Singleton

      def self.instance
        @instance ||= {}.tap do |options|
          if ::ClowderCommonRuby::Config.clowder_enabled?
            config = ::ClowderCommonRuby::Config.load
            options["awsAccessKeyId"]     = config.logging.cloudwatch.accessKeyId
            options["awsRegion"]          = config.logging.cloudwatch.region
            options["awsSecretAccessKey"] = config.logging.cloudwatch.secretAccessKey
            options["databaseHostname"]   = config.database.hostname
            options["databaseName"]       = config.database.name
            options["databasePassword"]   = config.database.password
            options["databasePort"]       = config.database.port
            options["databaseUsername"]   = config.database.username
            options["metricsPort"] = config.metricsPort
            # there might be more brokers but not relevant at this moment
            broker                 = config.kafka.brokers.first
            options["kafkaHost"]   = broker.hostname
            options["kafkaPort"]   = broker.port

            # requested and real topic names can be somewhere(?) different
            # but they'll be equal for stage and prod (app-interface)
            options["kafkaTopics"] = {}.tap do |topics|
              config.kafka.topics.each do |topic|
                # topic.consumerGroupName not used yet
                topics[topic.requestedName.to_s] = topic.name.to_s
              end
            end
            options["logGroup"]    = config.logging.cloudwatch.logGroup
            options["metricsPath"] = config.metricsPath # PrometheusExporter doesn't support custom path!
            options["webPorts"]    = config.webPort

          else
            options["awsAccessKeyId"]     = ENV['CW_AWS_ACCESS_KEY_ID']
            options["awsRegion"]          = "us-east-1"
            options["awsSecretAccessKey"] = ENV['CW_AWS_SECRET_ACCESS_KEY']
            options["databaseHostname"]   = ENV['DATABASE_HOST']
            options["databaseName"]       = ENV['DATABASE_NAME']
            options["databasePassword"]   = ENV['DATABASE_PASSWORD']
            options["databasePort"]       = ENV['DATABASE_PORT']
            options["databaseUsername"]   = ENV['DATABASE_USER']
            options["kafkaHost"]          = ENV['QUEUE_HOST'] || "localhost"
            options["kafkaPort"]          = (ENV['QUEUE_PORT'] || "9092").to_i
            options["kafkaTopics"]        = {}
            options["logGroup"]           = "platform-dev"
            options["metricsPort"]        = (ENV['METRICS_PORT'] || 9394).to_i
            options["webPorts"]           = 3000
          end
        end
      end

      def self.kafka_topic(name)
        instance["kafkaTopics"][name] || name
      end
    end
  end
end

# ManageIQ Message Client depends on these variables
ENV["QUEUE_HOST"] = Sources::Api::ClowderConfig.instance["kafkaHost"]
ENV["QUEUE_PORT"] = Sources::Api::ClowderConfig.instance["kafkaPort"].to_s

# ManageIQ Logger depends on these variables
ENV['CW_AWS_ACCESS_KEY_ID']     = Sources::Api::ClowderConfig.instance["awsAccessKeyId"]
ENV['CW_AWS_SECRET_ACCESS_KEY'] = Sources::Api::ClowderConfig.instance["awsSecretAccessKey"]
