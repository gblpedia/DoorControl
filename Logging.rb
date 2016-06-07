require 'logger'

module Logging

  # This is the magical bit that gets mixed into your classes
  def logger
  	Logging.logger.level = Logger::DEBUG
  	Logging.logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    #@logger ||= Logger.new('access.log')
    @logger ||= Logger.new(STDOUT)
  end
end