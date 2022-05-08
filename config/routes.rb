# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'videos#index'
  resources :videos
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
