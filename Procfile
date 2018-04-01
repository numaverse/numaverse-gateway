web: bundle exec rake db:schema:cache:dump && bundle exec puma -C config/puma.rb
worker: bundle exec rake db:schema:cache:dump && bundle exec sidekiq
