Rails.application.routes.draw do
  get 'auth/login' => 'authentication#login', as: :login
  get 'auth/sign' => 'authentication#sign', as: :auth_sign
  delete 'auth/logout' => 'authentication#logout', as: :logout

  root to: 'pages#home'

  get '/all' => 'pages#home', as: :all
  get '/welcome' => 'pages#welcome', as: :welcome
  get '/faucet' => 'pages#faucet', as: :faucet
  post '/faucet_captcha' => 'pages#faucet_captcha', as: :faucet_captcha

  resources :accounts, path: 'u', only: [:show, :edit, :update] do
    member do
      post :transfer
      post :attach_transaction
    end
  end

  resources :follows do
    member do
      post :attach_transaction
    end
  end

  resources :favorites do
    member do
      post :attach_transaction
    end
  end

  resources :messages, except: [:index] do
    member do
      post :refresh
      post :repost
      post :reply
      post :attach_transaction
    end
  end

  post '/upload_avatar' => 'pages#upload_avatar', as: :upload_avatar

  resources :blocks, only: [:index, :show]
  resources :transactions, only: [:index, :show]

  # ActivityPub routes
  get '/activity_pub/:account_id/outbox' => 'activity_pub#outbox', as: :ap_outbox
  get '/activity_pub/:account_id/account' => 'activity_pub#account', as: :ap_account
  get '/activity_pub/:account_id/inbox' => 'activity_pub#inbox', as: :ap_inbox
  get '/activity_pub/:account_id/followers' => 'activity_pub#followers', as: :ap_followers
  get '/activity_pub/:account_id/following' => 'activity_pub#following', as: :ap_following
  post '/activity_pub/:account_id/inbox' => 'activity_pub#inbox_incoming_message'
  get '/activity_pub/:message_id/message' => 'activity_pub#message', as: :ap_message
  get '/activity_pub/:version_id/activity' => 'activity_pub#activity', as: :ap_activity
  get '/.well-known/webfinger' => 'activity_pub#webfinger', as: :webfinger

  mount Sidekiq::Web => '/sidekiq'
end
