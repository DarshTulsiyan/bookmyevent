Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "home#index"

  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy", as: :logout

  get "/account", to: "home#account", as: :account

  get "/admin", to: "admin#dashboard", as: :admin
  get "/admin/users", to: "admin#users", as: :admin_users
  get "/admin/events/pending", to: "admin#pending_events", as: :admin_pending_events
  get "/admin/events/published", to: "admin#published_events", as: :admin_published_events
  get "/admin/events/rejected", to: "admin#rejected_events", as: :admin_rejected_events

  resources :events, only: %i[index show new create edit update] do
    post "tiers", to: "ticket_tiers#create", as: :tiers
    patch "tiers/:tier_id", to: "ticket_tiers#update", as: :tier
    delete "tiers/:tier_id", to: "ticket_tiers#destroy"
  end
end
