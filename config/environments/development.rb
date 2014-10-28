Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
  config.active_record.migration_error = :page_load
  
  config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new
  
  logger = Logger.new(STDOUT)
  logger = ActiveSupport::TaggedLogging.new(logger) if defined?(ActiveSupport::TaggedLogging)
  config.logger = logger
  log_level_env_override = Logger.const_get(ENV['LOG_LEVEL'].try(:upcase)) rescue nil
  config.logger.level = log_level_env_override || Logger.const_get(Rails.configuration.log_level.to_s.upcase)
  

  config.active_support.deprecation = :log
end
