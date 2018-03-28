require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Numa
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/lib"
    # config.autoload_paths += %W(#{config.root}/../ethereum.rb/lib)
    # config.autoload_paths += Dir["#{config.root}/../ethereum.rb/lib/**/"]
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec
    end

    require 'open-uri'
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379")
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

    config.redis = redis
    Split.redis = redis

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
