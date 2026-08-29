Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  resources :topics, only: [ :index ] do
    resources :threads, only: [ :index, :show, :new, :create, :edit, :update ] do
      member do
        post :react
      end

      resources :comments, only: [ :create ] do
        member do
          post :react
        end
      end
    end
  end

  resource :onboarding, only: [ :show, :update ], controller: "onboardings"
  resource :profile, only: [ :show, :update ], controller: "profiles"

  resources :regions, only: [] do
    resources :communes, only: [ :index ], module: :regions
  end

  if Rails.env.local?
    get "authorization_test", to: "authorization_test#index"
  end
end
