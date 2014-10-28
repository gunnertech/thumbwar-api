Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.serve_static_assets = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.digest = true

  config.log_level = :info
  config.log_formatter = ::Logger::Formatter.new
  
  logger = Logger.new(STDOUT)
  logger = ActiveSupport::TaggedLogging.new(logger) if defined?(ActiveSupport::TaggedLogging)
  config.logger = logger
  log_level_env_override = Logger.const_get(ENV['LOG_LEVEL'].try(:upcase)) rescue nil
  config.logger.level = log_level_env_override || Logger.const_get(Rails.configuration.log_level.to_s.upcase)
  
  config.i18n.fallbacks = true
  
  config.active_support.deprecation = :notify

  config.active_record.dump_schema_after_migration = false
end
