SocialMatchingSystem::Application.routes.draw do
  namespace :admin do
    resources :users
  end
  namespace :sender do
    resources :users
  end
  namespace :receiver do
    resources :users
  end

  resources :user_sessions
  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  root :to => "user_sessions#new"
end
