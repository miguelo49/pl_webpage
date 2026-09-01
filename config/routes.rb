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

  resources :news, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      post :react
    end
  end

  get "political_contexts", to: redirect("/")

  resources :events, only: [ :index, :show, :new, :create ] do
    member do
      get :calendar
    end

    resource :attendance, only: [ :create, :update ]
  end

  resources :training_materials, only: [ :index, :show, :new, :create ] do
    member do
      get :download
      post :bookmark
      post :read_mark
    end
  end

  resources :initiatives, only: [ :index, :show ] do
    member do
      patch :change_status
      post :react
      post :attach_documents
      post :comments, action: :create_comment
    end
  end

  post "initiatives/:initiative_id/comments/:id/react",
       to: "initiatives#react_comment",
       as: :react_initiative_comment

  resources :law_proposals, only: [ :index, :show ]

  resources :threads, only: [ :index ]

  namespace :moderation do
    root to: "queue#index"
    resources :reports, only: [ :index ]
    patch "items/:type/:id", to: "items#update", as: :item
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [ :index, :edit, :update ]
    resources :moderators, only: [ :index, :create, :destroy ]
    resources :regions
    resources :communes
    resources :topics
    resources :training_categories
  end

  resources :topics, only: [] do
    resources :threads, only: [ :show, :new, :create, :edit, :update ] do
      member do
        post :react
        post :bookmark
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
