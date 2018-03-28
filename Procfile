web: bundle exec rake db:schema:cache:dump && bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake db:schema:cache:dump && bundle exec sidekiq
