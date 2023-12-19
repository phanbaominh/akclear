# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount GoodJob::Engine => 'good_job'
  get 'operators/show'
  localized do
    get  'sign_in', to: 'sessions#new'
    post 'sign_in', to: 'sessions#create'
    get  'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
    get 'admin', to: 'admin#show'
    namespace :admin do
      resource :game_data_import, only: %i[create]
      resource :channels_import, only: %i[create]
      resources :clear_jobs, controller: 'extract_clear_data_from_video_jobs'
      resources :videos_imports, only: %i[new create]
      resource :clear_from_job, only: %i[new]
      resources :users, only: %i[index update edit show]
    end
    resources :sessions, only: %i[index show destroy]
    resource  :password, only: %i[edit update]
    resource  :username, only: %i[edit update]
    namespace :identity do
      resource :email,              only: %i[edit update]
      resource :email_verification, only: %i[show create]
      resource :password_reset,     only: %i[new edit create update]
    end
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Defines the root path route ("/")
    root 'home#index'
    resources :healthz, only: %i[index]

    resources :channels, only: %i[index show]
    namespace :clears do
      resource :filters, only: %i[show]
      resource :stage_select, only: %i[show]
      resource :operators_select, only: %i[show]
      resource :used_operator
    end
    resources :clears do
      resources :used_operators
      resource :like, only: %i[create destroy], controller: 'clears/likes'
      resource :report, only: %i[create destroy], controller: 'clears/reports'
      resource :verification, only: %i[edit update create destroy new], controller: 'clears/verifications'
      namespace :verification do
        resources :used_operators, only: %i[edit update], controller: '/clears/verifications/used_operators'
      end
    end
    resources :operators
  end
end
# rubocop:enable Metrics/BlockLength
