SocialMatchingSystem::Application.routes.draw do

  namespace :admin do
    resources :users
    resources :addresses
  end

  namespace :sender do
    resources :users
    resources :massages
  end

  namespace :receiver do
    resources :users
    resources :massages
  end

  resources :user_sessions

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  root :to => "user_sessions#new"
end
