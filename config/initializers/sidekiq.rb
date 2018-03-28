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
end

Sidekiq.configure_client do |config|
  config.redis = { url: uri, namespace: namespace }
  # Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
end