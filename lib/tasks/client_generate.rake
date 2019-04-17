#
# Usage: bundle exec rake client:generate
#        bundle exec rake client:generate[/alternate_ruby_client_dir]
#
class ClientGenerator
  require 'json'
  require 'uri'

  VERSION = "3.3.4".freeze
  SOURCE_URL = "http://central.maven.org/maven2/org/openapitools/openapi-generator-cli".freeze

  def msg(message)
    STDOUT.puts(message)
  end

  def api_version
    @api_version ||= Rails.application.routes.routes.each_with_object([]) do |route, array|
      matches = ActionDispatch::Routing::RouteWrapper
                .new(route)
                .path.match(/\A.*\/v(\d+.\d+)\/openapi.json.*\z/)
      array << matches[1] if matches
    end.max
  end

  def generator_cli_jar
    @generator_cli_jar ||= begin
      jar_path = Pathname.new(Rails.root.join("public/doc/openapi-generator-cli-#{VERSION}.jar"))
      unless File.exist?(jar_path) && File.size(jar_path).positive?
        source_url = "#{SOURCE_URL}/#{VERSION}/openapi-generator-cli-#{VERSION}.jar"
        cli_res = Net::HTTP.get_response(URI(source_url))
        raise "Failed to get the #{source_url} - #{cli_res.message}" unless cli_res.kind_of?(Net::HTTPSuccess)

        File.open(jar_path, "wb") { |jar_fp| jar_fp.write(cli_res.body) }
      end
      jar_path
    end
  end

  def generator_config
    @generator_config ||= Pathname.new(Rails.root.join(".openapi_generator_config.json")).to_s
  end

  def openapi_file
    @openapi_file ||= Pathname.new(Rails.root.join("public/doc/openapi-3-v#{api_version}.0.json")).to_s
  end

  def openapi_yaml_file
    @openapi_yaml_file ||= Pathname.new(Rails.root.join("public/doc/openapi-3-v#{api_version}.0.generator.yaml")).to_s
  end

  def generate_yaml_file(json_spec, yaml_spec)
    File.write(yaml_spec, JSON.parse(File.read(json_spec)).to_yaml(:line_width => -1).sub("---\n", "").tap { |c| c.gsub!("- NULL VALUE", "- null") })
  end

  def generate_ruby_client(client_dir)
    msg("Sources API Version: #{api_version}")
    msg("Using OpenAPI Generator CLI Jar:   #{generator_cli_jar}")
    msg("OpenAPI 3.0 Specification File:    #{openapi_file}")
    msg("OpenAPI 3.0 Specification Yaml:    #{openapi_yaml_file}")
    msg("OpenAPI Generator Config:          #{generator_config}")

    msg("\nGenerating API Ruby Client ...")
    generate_yaml_file(openapi_file, openapi_yaml_file)
    system("java -jar #{generator_cli_jar} generate -i #{openapi_yaml_file} -c #{generator_config} -g ruby -o #{client_dir}")
  end
end

namespace :client do
  desc "Generate the Toplogical Inventory API Ruby Client"
  task :generate, [:client_dir] => [:environment] do |_task, args|
    default_client_dir = Pathname.new(Rails.root.join("..", "sources-api-client-ruby"))
    args.with_defaults(:client_dir => default_client_dir)
    ClientGenerator.new.generate_ruby_client(args[:client_dir])
  end
end
