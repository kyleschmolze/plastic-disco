Rails.application.routes.draw do
  resources :users

  resources :videos, only: [:index, :show], param: :google_id

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  root to: 'videos#index'
end
