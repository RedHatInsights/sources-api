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
