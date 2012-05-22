SocialMatchingSystem::Application.routes.draw do

  namespace :admin do
    resources :users
    resources :massages
    resources :global_settings,:only => %w[edit update]
    resources :receivers_locations,:only=>%W[index show]
  end

  namespace :sender do
    #resources :users   現時点で使用してないコントローラ
    #resources :addresses　現時点で使用してないコントローラ
    resources :massages do
      put :change_status, :on => :member
    end
  end

  namespace :receiver do
    #resources :users　現時点で使用してないコントローラ
    resources :massages do
      put :reject,:on => :member
      get :map,:on => :member
    end
    resources :receivers_locations, :only=>:create
  end

  resources :user_sessions

  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  get "top/index"

  root :to => "user_sessions#new"
end
