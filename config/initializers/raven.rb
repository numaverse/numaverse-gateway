Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end if ENV['SENTRY_DSN'].present?