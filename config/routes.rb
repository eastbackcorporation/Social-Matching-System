SocialMatchingSystem::Application.routes.draw do

  namespace :admin do
    resources :users
    resources :addresses
    resources :massages
    resources :global_settings,:only => %w[edit update]
    resources :receivers_locations,:only=>%W[index show]
  end

  namespace :sender do
    resources :users
    resources :addresses
    resources :massages do
      put :change_status, :on => :member
    end
  end

  namespace :receiver do
    resources :users
    resources :massages do
      put :reject,:on => :member
      get :map,:on => :member
    end
    resources :receivers_locations
  end

  resources :user_sessions

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  root :to => "user_sessions#new"
end
