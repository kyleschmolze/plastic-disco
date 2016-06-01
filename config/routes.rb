Rails.application.routes.draw do
  resources :highlights
  resources :users

  resources :events, only: [:index, :show] do
    get :search, on: :collection
  end

  resources :videos, only: [:index, :show, :update] do
    post :align_to_event, on: :member
    post :unalign, on: :member
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  root to: 'highlights#index'
end
