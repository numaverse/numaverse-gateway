Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username_match = ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"]))
  password_match = ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  username_match & password_match
end if Rails.env.production?

uri = ENV["REDISTOGO_URL"] || "redis://localhost:6379/0"
app_name = "numaverse"
namespace = "#{app_name}_#{Rails.env}"

# schedule_file = "config/sidekiq_schedule.yml"
# if Rails.env.production?
#   schedule_file = "config/sidekiq-scheduler-prod.yml"
# end

Sidekiq.configure_server do |config|
  config.redis = { url: uri, namespace: namespace }

  # Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  Rails.application.config.after_initialize do
    Rails.logger.info("DB Connection Pool size for Sidekiq Server before disconnect is: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
    ActiveRecord::Base.connection_pool.disconnect!

    ActiveSupport.on_load(:active_record) do
      config = Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
      # config['pool'] = ENV['WORKER_DB_POOL_SIZE'] || Sidekiq.options[:concurrency]
      config['pool'] = 16
      ActiveRecord::Base.establish_connection(config)

      Rails.logger.info("DB Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: uri, namespace: namespace }
  # Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
end