Rails.application.routes.draw do
  # Non-locale-scoped routes
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
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Locale-scoped routes
  scope "(:locale)", locale: /en|ru|kg/ do
    resources :articles
    resources :internal_client_profiles
    resources :client_profiles
    resources :issues do
      collection { get :filtered }
    end
    resources :psychological_issues
    resources :client_types
    resources :specialties

    # Static pages
    get 'find-a-psychologist', to: 'psychologist_profiles#search_landing', as: :search_landing
    get 'for-psychologists', to: 'psychologist_profiles#landing_psych', as: :landing_psych
    get 'contact-us', to: 'psychologist_profiles#contact_us', as: :contact_us

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
    end

    # Psychologist profiles and nested resources
    resources :psychologist_profiles do
      resources :educations, only: [:new, :create, :edit, :update, :destroy]
      resources :psychologist_availabilities, except: [:show] do
        collection { get 'calendar_blocks' }
      end
      resources :bookings, only: [:create, :show, :index, :update, :edit, :destroy] do
        collection do
          get 'calendar_bookings'
          get 'psychologist_bookings'
          post :create_json
        end
        member do
          get 'confirm', to: 'bookings#confirm_form'
          post 'confirm'
          post 'decline'
          patch :update_json
          delete :destroy_json
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

    # Therapy plans and progress notes
    resources :internal_client_profiles do
      resources :therapy_plans do
        resources :progress_notes
      end
    end
  end

  # Root route
  root "psychologist_profiles#index"
end
# Rails.application.routes.draw do
#   resources :articles
#   get "psychologist_dashboard/index"
#   # ✅ These MUST be outside of locale scope
#   direct :rails_blob do |blob|
#     route_for(:rails_service_blob, blob.signed_id, blob.filename)
#   end

#   direct :rails_blob_variant do |variant|
#     route_for(:rails_blob_representation, variant.blob.signed_id, variant.variation.key, variant.blob.filename)
#   end

#   resources :quizzes do
#     member do
#       get 'take'
#       post 'submit'
#       get 'result'
#     end
#   end
#   # ✅ Locale-scoped routes
#   scope "(:locale)", locale: /en|ru|kg/ do
#     resources :internal_client_profiles
#     resources :client_profiles
#     resources :issues do
#       collection { get :filtered }
#     end

#     resources :psychological_issues
#     resources :client_types
#     resources :specialties

#     get 'find-a-psychologist', to: 'psychologist_profiles#search_landing', as: :search_landing
#     get 'for-psychologists', to: 'psychologist_profiles#landing_psych', as: :landing_psych
#     get 'contact-us', to: 'psychologist_profiles#contact_us', as: :contact_us

#     post '/set_currency', to: 'application#set_currency', as: :set_currency

#     devise_for :users, controllers: {
#       registrations: 'users/registrations',
#       confirmations: 'users/confirmations'
#     }

#     resources :services do
#       resources :bookings, only: [:new]
#     end

#     resources :bookings, only: [:create, :show, :index, :update, :edit, :destroy] do
#       collection do
#         get 'calendar_bookings'
#         get 'psychologist_bookings'
#         post :create_json
#       end
#       member do
#         get 'confirm', to: 'bookings#confirm_form'
#         post 'confirm'
#         post 'decline'
#         patch :update_json
#         delete :destroy_json
#       end
#     end

#     post '/set_timezone', to: 'application#set_timezone', as: :set_timezone_path

#     resources :psychologist_profiles do
#       resources :educations, only: [:new, :create, :edit, :update, :destroy]

#       collection do
#         post 'toggle_filter'
#       end

#       resources :psychologist_availabilities, except: [:show] do
#         collection { get 'calendar_blocks' }
#       end

#       resources :psychologist_unavailabilities, only: [:index, :create, :update, :destroy] do
#         collection do
#           get :calendar
#           get :index
#           post :create_json
#         end
#         member do
#           patch :update_json
#           delete :destroy_json
#         end
#       end
#     end
#     # Psychologist Dashboard
#     get '/dashboard', to: 'psychologist_dashboard#index', as: 'psychologist_dashboard'

#     get '/calendar', to: 'psychologist_unavailabilities#calendar'
#     get 'psychologist_profiles/:psychologist_profile_id/calendar', to: 'psychologist_unavailabilities#calendar', as: :psychologist_profile_calendar

#     resources :internal_client_profiles do
#       resources :therapy_plans do
#         resources :progress_notes
#       end
#     end
#   end

#   # Global routes (not locale-scoped)
#   get "up" => "rails/health#show", as: :rails_health_check

#   root "psychologist_profiles#index"
# end
