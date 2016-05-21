Rails.application.routes.draw do
  resources :users

  resources :events, only: [:index, :show]

  resources :videos, only: [:index, :show], param: :google_id do
    get :import, on: :collection
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  root to: 'videos#index'
end
