
Rails.application.routes.draw do
  # Home and authentication
  root "login#index"

  get "login", to: "login#index"
  post "login", to: "login#create"

  get "register", to: "login#register"
  post "register", to: "login#create_account"

  delete "logout", to: "login#logout"

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Members: create, edit, delete
  resources :members, only: %i[create update destroy]

  # Installments: edit and delete
  resources :installments, only: %i[update destroy] do
    resource :payment, only: [:create], controller: "payments"
  end

  # Payments: delete
  resources :payments, only: [:destroy]

  # Collection periods
  resources :collection_periods, only: %i[new create]

  post "collection_periods/:id/generate_installments",
       to: "collection_periods#generate_installments",
       as: :generate_collection_installments

  # Rails health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Optional PWA routes
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
