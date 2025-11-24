Rails.application.routes.draw do


# config/routes.rb
  namespace :admin do
    resources :psychologist_reviews, only: [:index, :show] do
      member do
        patch :update_all
      end
    end
  end




  get "analytics/index"
  get "analytics/show"
  resources :analytics, only: [] do
    collection do
      get :scroll_stats
      get :page_links   # 👈 new route
    end
  end
  # Non-locale-scoped routes
  post "/telegram/webhook", to: "telegrams#webhook"

  resources :page_view_events, only: [:create]

  get '/p/:profile_url', to: 'psychologist_profiles#redirect_by_profile_url', as: :profile_shortlink

  direct :rails_blob do |blob|
    route_for(:rails_service_blob, blob.signed_id, blob.filename)
  end

  direct :rails_blob_variant do |variant|
    route_for(:rails_blob_representation, variant.blob.signed_id, variant.variation.key, variant.blob.filename)
  end

  resources :quizzes do
    member do
      get 'take'
      post 'submit'
      get 'result'
      get  :edit_questions
      patch :update_questions
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check


  # Locale-scoped routes
  scope "(:locale)", locale: /en|ru|kg/ do

      get "pages/home"
      get "pages/about_for_psych"
      get "pages/about_for_clients"
      get "pages/contact"
      get "pages/how_to"


    resources :events do
      member do
        get :share                    # /events/:id/share       → Share/copy link
        patch :cancel                  # /events/:id/cancel      → Cancel event
        patch :archive                 # /events/:id/archive     → Archive event
        get :duplicate                 # /events/:id/duplicate   → Duplicate event
      end

      resources :event_registrations, only: [:create, :new, :show, :edit, :update] do
        member do
          patch :approve               # /events/:event_id/event_registrations/:id/approve
          patch :decline               # /events/:event_id/event_registrations/:id/decline
          patch :cancel                # /events/:event_id/event_registrations/:id/cancel
          patch :mark_attended         # /events/:event_id/event_registrations/:id/mark_attended
          patch :mark_no_show          # /events/:event_id/event_registrations/:id/mark_no_show
        end
      end
    end


    get '/book/select_service', to: 'bookings#select_service', as: :select_service
    get '/book/choose_time', to: 'bookings#choose_time', as: :choose_time
    get '/book/assign_client', to: 'bookings#assign_client', as: :assign_client
    post '/book/assign_client', to: 'bookings#assign_client'
    post '/book/confirm', to: 'bookings#confirm_booking', as: :confirm_booking


    resources :client_infos, only: [:index, :new, :show, :create, :edit, :update, :destroy]
    resources :articles
    resources :client_profiles
    resources :issues do
      collection { get :filtered }
    end
    resources :psychological_issues
    resources :client_types
    resources :specialties do
      member do
        get :definition
      end
    end
    
    # Static pages
    get 'find-a-psychologist', to: 'psychologist_profiles#search_landing', as: :search_landing
    get 'for-psychologists', to: 'psychologist_profiles#landing_psych', as: :landing_psych
    get 'contact-us', to: 'psychologist_profiles#contact_us', as: :contact_us
    get '/psychologist_profiles/check_email', to: 'psychologist_profiles#check_email', as: :psychologist_check_email
    #telegram
    resource :telegram, only: [:show] do
      post :regenerate_code, on: :collection
    end

    # Currency and timezone settings
    post '/set_currency', to: 'application#set_currency', as: :set_currency
    post '/set_timezone', to: 'application#set_timezone', as: :set_timezone_path

    # Devise for user authentication
    devise_for :users, controllers: {
      registrations: 'users/registrations',
      confirmations: 'users/confirmations'
    }

    # Services and nested bookings
    resources :services do
      resources :bookings, only: [:new]
      member do
        patch :archive
        patch :unarchive
      end
    end

    # Psychologist profiles and nested resources
    resources :psychologist_profiles do
       collection do
          get :check_profile_url  # <-- add this here
        end
      member do 
         get :analytics  # /psychologist_profiles/:id/analytics
      end
      get :available_slots, on: :member
      resources :services, only: [:index, :show, :edit, :destroy, :new]
      resources :client_infos, only: [:index,:new, :create, :edit,:update, :destroy, :show]
      resources :educations, only: [:new, :create, :edit, :update, :destroy]
      resources :psychologist_availabilities, only: [:index, :create, :update] do
        collection do 
          get 'calendar_blocks' 
           #patch '/', to: 'psychologist_availabilities#update', as: 'update_all'
          patch 'update_all'
        end
      end
      resources :bookings, only: [:create, :new, :show, :index, :update, :edit, :destroy] do
        collection do
          get 'calendar_bookings'
          get 'psychologist_bookings'
          post :create_json
          get :new_with_service_selection
          get :show_all
        end
        member do
          get 'confirm', to: 'bookings#confirm_form'
          patch 'confirm'
          patch 'cancel'
          patch 'decline'
          patch :update_json
          delete :destroy_json
          get :download_ics

        end
      end
      resources :psychologist_unavailabilities, only: [:index, :create, :update, :destroy] do
        collection do
          get :calendar
          post :create_json
        end
        member do
          patch :update_json
          delete :destroy_json
        end
      end
      collection do
        post 'toggle_filter'
      end
    end

    # Psychologist dashboard
    get '/dashboard', to: 'psychologist_dashboard#index', as: :psychologist_dashboard

    # Calendar routes
    get '/calendar', to: 'psychologist_unavailabilities#calendar'
    get 'psychologist_profiles/:psychologist_profile_id/calendar', to: 'psychologist_unavailabilities#calendar', as: :psychologist_profile_calendar

  end

  # Root route
  root "pages#home"
end
