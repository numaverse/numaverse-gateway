require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'
ENV['RPC_ADDRESS'] = "http://localhost:8555"
ENV.delete 'IPFS_USER'
ENV.delete 'IPFS_PASSWORD'
ENV['IPFS_ADDRESS'] = "http://localhost"
ENV['IPFS_PORT'] = "5001"

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/cassettes'
  c.hook_into :webmock
  c.ignore_request do |request|
    port = URI(request.uri).port
    [8555, 5001].include?(port)
  end
  c.ignore_localhost = false
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include BlockchainTestHelpers
  config.include ActivityPubSpecHelpers
  config.include ActiveJob::TestHelper
  # config.full_backtrace = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, :end_to_end) do
    deploy_contracts!
  end

  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end
