if Rails.env != "test" && ENV['METRICS_PORT'].to_i != 0
  require 'prometheus_exporter/middleware'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift(PrometheusExporter::Middleware)
end
