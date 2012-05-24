SocialMatchingSystem::Application.routes.draw do

  namespace :admin do
    resources :users do
      get :edit_password, :on => :member
      put :update_password, :on => :member
    end
    resources :massages do
      put :change_status, :on => :member
    end
    resources :addresses, :only => %W[new edit create update]
    resources :global_settings,:only => %w[edit update]
    resources :receivers_locations,:only=>%W[index show]
  end

  namespace :sender do
    #resources :users   現時点で使用してないコントローラ
    resources :addresses do
      post :confirm, :on => :collection
      post :new , :on => :member
    end
    resources :massages do
      put :change_status, :on => :member
      post :confirm, :on => :collection
      post :new , :on => :member
    end
  end

  namespace :receiver do
    #resources :users　現時点で使用してないコントローラ
    resources :massages do
      put :reject,:on => :member
      put :change_status, :on => :member
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
