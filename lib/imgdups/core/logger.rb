require 'logger'

#==============================================================================
#
module LogAware

  class TreeLogger

    def initialize(indent = "", log_file )
      @indent = indent
      @log_file = log_file

      @logger = init_logger()
      @branches = Array.new()
    end

    private def init_logger()
      logger = nil
      if(@log_file == nil)
        logger = Logger.new(STDOUT)
      else
        file = File.open(@log_file , File::WRONLY | File::APPEND)
        logger = Logger.new(@file)
      end

      logger.level = Logger::DEBUG
      #logger.level = Logger::INFO

      return logger
    end

    def branch()
      new_loggger = init_logger()
      @branches.push(new_loggger)
      return new_loggger
    end

    def info(message)
      log(message)
    end

    def debug(message)
      log(message)
    end

    def log(message)
      message = "#{@indent}#{message}"
      @logger.info(message)
    end

  end
end
