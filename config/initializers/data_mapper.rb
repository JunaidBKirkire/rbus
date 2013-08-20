DataMapper::Logger.new($stdout, :debug)
DataMapper.logger.level = DataMapper::Logger::Levels[:debug]
