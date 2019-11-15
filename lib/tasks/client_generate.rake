#
# Usage: bundle exec rake client:generate
#        bundle exec rake client:generate[/alternate_client_dir, alternate_client_lang]
#
class ClientGenerator
  require 'json'
  require 'uri'

  VERSION = "4.2.1".freeze
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
        require "net/http"

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

  # Remove source files which are not present but won't be deleted by the generator-cli jar
  def clean_target_directories(client_dir)
    FileUtils.rm_r(client_dir.join("docs")) if client_dir.join("docs").exist?
    FileUtils.rm_r(client_dir.join("spec")) if client_dir.join("spec").exist?
    FileUtils.rm_r(client_dir.join("lib"))  if client_dir.join("lib").exist?
  end

  def generate_client(client_dir, lng)
    msg("Sources API Version: #{api_version}")
    msg("Using OpenAPI Generator CLI Jar:   #{generator_cli_jar}")
    msg("OpenAPI 3.0 Specification File:    #{openapi_file}")
    msg("OpenAPI 3.0 Specification Yaml:    #{openapi_yaml_file}")
    msg("OpenAPI Generator Config:          #{generator_config}")

    msg("\nGenerating API #{lng} Client ...")
    generate_yaml_file(openapi_file, openapi_yaml_file)
    clean_target_directories(client_dir)
    system("java -jar #{generator_cli_jar} generate -i #{openapi_yaml_file} -c #{generator_config} -g #{lng} -o #{client_dir}")
  end
end

namespace :client do
  desc "Generate the Sources API Client (by default in Ruby)"
  task :generate, [:client_dir, :language] => [:environment] do |_task, args|
    args.with_defaults(:language => "ruby")
    default_client_dir = Pathname.new(Rails.root.join("..", "sources-api-client-#{args[:language]}"))
    args.with_defaults(:client_dir => default_client_dir)
    ClientGenerator.new.generate_client(args[:client_dir], args[:language])
  end
end
