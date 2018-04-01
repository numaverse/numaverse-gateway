source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'bootstrap', '~> 4.0.0.beta3'
gem 'jquery-rails'
gem 'haml-rails'
gem 'awesome_print'
gem 'google-analytics-rails'
gem 'paper_trail'
gem 'nokogiri'
gem 'dalli'
gem 'split', require: 'split/dashboard'
gem 'rails_12factor'
gem 'unicorn'
gem 'hashie'
gem 'memcachier'
gem 'font-awesome-rails'
gem 'sidekiq', require: 'sidekiq/web'
gem 'money-tree', github: 'numaverse/money-tree', branch: 'numa'
gem 'ethereum.rb', github: 'numaverse/ethereum.rb', branch: 'numa'
gem 'eth'
gem "attr_encrypted", "~> 3.0.0"
gem 'faker'
gem 'redcarpet', '~> 3.4.0'
gem 'sanitize', '~> 4.6.3'
gem 'loofah', '~> 2.2.1'
gem 'gutentag', '~> 2.0.0'
gem 'money-rails', '~>1'
gem 'textacular', '~> 5.0'
gem 'kaminari'
gem 'ipfs', require: 'ipfs/client', github: 'numaverse/ipfs-ruby', branch: 'numa'
gem 'base58'
gem 'json-schema'
gem 'cancancan', '~> 2.0'
gem 'json', '~> 1.8'
gem "recaptcha", require: "recaptcha/rails"
gem 'aasm'
gem 'goldfinger', '~> 2.1'
gem 'httparty', '~> 0.13.7'
gem "sentry-raven"
gem 'redis-namespace'
gem 'redis-rails'
gem 'sinatra', '~> 2.0.1'
gem 'rails-html-sanitizer', '~> 1.0.4'
group :test, :development do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  # gem 'capybara-webkit'
  gem 'guard'
  gem 'rack-livereload'
  gem 'guard-rails'
  gem 'guard-livereload'
  gem 'ruby_gntp'
  gem 'rb-fsevent'
  gem 'mocha', require: false
  gem 'thor', '~> 0.19.0'
  gem 'rails-erd'
  gem 'lorem-ipsum'
  gem 'launchy'
  gem 'ruby-progressbar'
  gem 'better_errors'
  gem 'database_cleaner'
  gem 'binding_of_caller'
  gem 'vcr'
  gem 'simplecov', require: false
  gem 'guard-sidekiq'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'dotenv-rails'
  gem 'rubocop'
  gem 'pronto'
  gem 'pronto-rubocop', require: false
  gem 'rails-controller-testing'
  gem 'brakeman', require: false
end

group :test do
  gem 'webmock', '< 1.16'
end