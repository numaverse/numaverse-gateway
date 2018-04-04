Rails.application.routes.draw do

  get 'auth/login' => 'authentication#login', as: :login
  get 'auth/sign' => 'authentication#sign', as: :auth_sign
  delete 'auth/logout' => 'authentication#logout', as: :logout

  root to: 'pages#home', constraints: lambda { |request| request.session['account_id'].present? }
  root to: 'pages#welcome'

  get '/all' => 'pages#home', as: :all
  get '/welcome' => 'pages#welcome', as: :welcome

  resources :accounts, path: 'u', only: [:show, :edit, :update] do
    member do
      post :transfer
      post :attach_transaction
    end
    collection do
      get :settings
      post :update_settings
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

  resources :messages do
    member do
      post :repost
      post :reply
      post :attach_transaction
      post :tip
    end
  end

  post '/upload_avatar' => 'pages#upload_avatar', as: :upload_avatar

  resources :blocks, only: [:index, :show]
  resources :transactions, only: [:index, :show]

  get 'batches/show'
  post 'batches/:id/upload' => 'batches#upload'
  post 'batches/:id/attach_transaction' => 'batches#attach_transaction'
  post 'batches/:id/cancel' => 'batches#cancel'

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

  namespace :federated do
    resources :accounts, only: [:show] do
      collection do
        get :search
      end
    end
    resources :follows, only: [:create, :destroy]
    resources :messages, only: [:index]
  end

  mount Sidekiq::Web => '/sidekiq'
end
