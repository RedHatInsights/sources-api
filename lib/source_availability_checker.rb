class SourceAvailabilityChecker
  attr_accessor :thread_available_checker, :thread_unavailable_checker

  AVAILABLE_SOURCE_CHECK_FREQUENCY_DEFAULT   = 60
  UNAVAILABLE_SOURCE_CHECK_FREQUENCY_DEFAULT = 10

  def self.instance(config = {})
    @instance ||= new(config)
  end

  def initialize(config)
    @config = config
    start_threads(config)
  end
  private_class_method :new

  private

  def start_threads(config)
    @thread_available_checker = Thread.new do
      interval = config.fetch_path(:available, :check_frequency) || AVAILABLE_SOURCE_CHECK_FREQUENCY_DEFAULT
      loop do
        sleep(interval)
        check_available_sources
      end
    end

    @thread_unavailable_checker = Thread.new do
      interval = config.fetch_path(:unavailable, :check_frequency) || UNAVAILABLE_SOURCE_CHECK_FREQUENCE_DEFAULT
      loop do
        sleep(interval)
        check_unavailable_sources
      end
    end
  end

  def check_available_sources
    puts "Checking Available Sources ..."
    puts ""
    Source.all.each do |source|
      puts "Checking source #{source.uid} ..."
    end
  end

  def check_unavailable_sources
    puts "Checking Unavailable Sources ..."
    puts ""
    Source.all.each do |source|
      puts "Checking source #{source.uid} ..."
    end
  end
end
