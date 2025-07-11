Rails.application.routes.draw do
  resources :internal_client_profiles
  resources :client_profiles
  resources :issues do
    collection do
      get :filtered
    end
  end

  resources :psychological_issues
  resources :client_types
  resources :specialties
  

  get 'find-a-psychologist', to: 'psychologist_profiles#search_landing', as: :search_landing
  get 'for-psychologists', to: 'psychologist_profiles#landing_psych', as: :landing_psych
  get 'contact-us', to: 'psychologist_profiles#contact_us', as: :contact_us


  post '/set_currency', to: 'application#set_currency', as: :set_currency

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations' # Custom controller

  }


   direct :rails_blob do |blob|
    route_for(:rails_service_blob, blob.signed_id, blob.filename)
  end
  direct :rails_blob_variant do |variant|
    route_for(:rails_blob_representation, variant.blob.signed_id, variant.variation.key, variant.blob.filename)
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # resources :psychologist_profiles do
  
  #     collection do
  #     post 'toggle_filter'
  #   end
  # end
  #bookings
# config/routes.rb
resources :services do
  resources :bookings, only: [:new]  # /services/:service_id/bookings/new
end

resources :bookings, only: [:create, :show, :index, :update, :edit, :destroy] do
  collection do
    get 'calendar_bookings'  # /bookings/calendar_bookings
  end
end

  resources :psychologist_profiles do
    collection do
      post 'toggle_filter'
    end

    resources :psychologist_availabilities, except: [:show] do
      collection do
        get 'calendar_blocks' # /psychologist_profiles/:id/psychologist_availabilities/calendar_blocks
      end
    end
  end

get '/calendar', to: 'psychologist_unavailabilities#calendar'
get 'psychologist_profiles/:psychologist_profile_id/calendar', to: 'psychologist_unavailabilities#calendar', as: :psychologist_profile_calendar

resources :psychologist_unavailabilities, only: [:index, :create, :destroy]










  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "psychologist_profiles#index"
end
