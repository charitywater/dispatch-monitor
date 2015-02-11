Rails.application.routes.draw do
  root to: 'dashboard#show'

  devise_for :accounts, skip: [:sessions]

  as :account do
    get '/login' => 'devise/sessions#new', as: :new_account_session
    post '/login' => 'devise/sessions#create', as: :account_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_account_session
  end

  resource :map, controller: :map, only: [:show]

  get 'projects/search', to: 'projects#search'
  
  namespace :map do
    resources :projects, only: [:show] do
      resources :activities, only: [:index]
      resources :tickets, only: [:index]
      resources :sensors, only: [:index]
    end
  end

  resource :settings, controller: :settings, only: [:edit, :update]

  resources :projects, only: [:index, :show, :edit, :update, :destroy] do
    resources :tickets, only: [:new, :create]
  end

  resources :tickets, only: [:index, :show, :destroy] do
    member do
      patch :complete
    end
  end

  resources :sensors, only: [:index, :new, :create, :destroy]
  resources :vehicles, only: [:index, :new, :create, :edit, :update]
  resources :weekly_logs, only: [:index, :show]

  namespace :admin do
    resources :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
    resource :application_settings, controller: :application_settings, only: [:edit, :update]
    resources :email_subscriptions, only: [:index, :new, :create, :destroy]
  end

  namespace :search do
    resources :projects, only: [:index]
  end

  namespace :import do
    resources :projects, only: [:new, :create]
    resources :surveys, only: [:new, :create]
  end

  namespace :webhook do
    resource :survey_responses, only: [:create]
  end

  namespace :gps do
    resource :receive, controller: :receive, only: [:create], defaults: { format: :xml }
  end

  get '/wazi_api/*path', to: 'wazi_api#proxy' if Rails.env.development?

  post 'sensors/receive', to: 'sensors/receive#create', defaults: { format: :json }

  resque_web_constraint = lambda do |request|
    current_account = request.env['warden'].user
    current_account.present? && current_account.admin?
  end

  constraints resque_web_constraint do
    mount Resque::Server, at: '/resque'
  end
end
