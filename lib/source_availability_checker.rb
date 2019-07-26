class SourceAvailabilityChecker
  attr_accessor :thread_available_checker, :thread_unavailable_checker

  def self.instance
    @instance ||= new
  end

  def initialize
    start_threads
  end
  private_class_method :new

  private

  def log
    Rails.logger
  end

  def start_threads
    @thread_available_checker = Thread.new do
      interval = ENV["AVAILABLE_SOURCE_CHECK_INTERVAL"] || 60
      loop do
        sleep(interval)
        check_available_sources
      end
    end

    @thread_unavailable_checker = Thread.new do
      interval = ENV["UNAVAILABLE_SOURCE_CHECK_INTERVAL"] || 10
      loop do
        sleep(interval)
        check_unavailable_sources
      end
    end
  end

  def check_available_sources
    check_sources = []

    Source.all.each do |source|
      next unless source_available(source)

      check_sources << source.id
      Sources::Api::Events.send_message(
        "platform.topological-inventory.operations-openshift",
        "Source.availability_check",
        :params => { :source_id => source.id.to_s }
      )
    end
    log.info("Requested Availability check for available sources [#{check_sources.join(', ')}]") if check_sources.present?
  rescue => err
    log.error(err)
  end

  def check_unavailable_sources
    check_sources = []

    Source.all.each do |source|
      next if source_available(source)

      check_sources << source.id
      Sources::Api::Events.send_message(
        "platform.topological-inventory.operations-openshift",
        "Source.availability_check",
        :params => { :source_id => source.id.to_s }
      )
    end
    log.info("Requested Availability check for unavailable sources [#{check_sources.join(', ')}]") if check_sources.present?
  rescue => err
    log.error(err)
  end

  def source_available(source)
    source.availability_status == "available"
  end
end
