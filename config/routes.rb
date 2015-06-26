PocketConcierge::Application.routes.draw do

  resources :invitation_codes
  resources :user_anniversaries
  resources :user_credit_cards, :path => "users/credit_cards"
  resources :contacts, :only => [:new, :create]
  resources :concierge_questions, :only => [:index, :new, :create, :show] do
    collection do
      post :account
      get :complete
      get :reserved_complete
      get :deny_complete
      get :lp
    end
    member do
      get :restaurant_course
      get :payment
      post :coupon
      post :paid
      get :confirm
      post :reserved
      post :deny
    end
  end

  delete "reservations/:reservation_id/message_destroy/:message_id", :to => "reservations#message_destroy", :as => "reservations_message_destroy"
  resources :reservations do
    get :complete
    collection do
      get :mail_open
      get :notice
      get "3d", :to => "reservations#three_dee"
    end
    member do
      get :cancel
      get :sendmail
      post :sendmail_confirm
      post :sendmail_create
      get :sendmail_complete
      get :message
      post :message_create
      get :questionnaire
      post :questionnaire_create
      get :questionnaire_complete
      get :new_card
      patch :new_card_create
      get :receipt
      get :receipt_pdf
    end
  end

  #devise_for :users, :controllers => {
  #  :sessions => 'users/sessions',
  #  :registrations => 'users/registrations',
  #  :passwords => 'users/passwords',
  #  :confirmations => 'users/confirmations',
  #  :omniauth_callbacks => "omniauth_callbacks"
  #}
  devise_for :users, :controllers => {
    :sessions => 'users/sessions',
    :registrations => 'users/registrations',
    :passwords => 'users/passwords',
    :confirmations => 'users/confirmations',
    :omniauth_callbacks => "users/omniauth_callbacks"
  }

  # devise_scope :user do
  #   get "line",
  #     to: "users/registrations#line",
  #     as: "line"
  #   get "obtain_request_token_for_line",
  #     to: "users/registrations#obtain_request_token_for_line",
  #     as: "obtain_request_token_for_line"
  # end

  get "login" , :to => "users#login", :as => "login"

  #devise_scope :user do
  #  post "users/facebook/create", :to => "users/omniauthCallbacks#create"
  #  get "users/facebook/deauthorize", :to => "users/Registrations#facebook_deauthorize", :as => "user_facebook_deauthorize"
  #end
  resources :users do
    collection do
      get :edit_user_append
      put :update_user_append
      get :edit_user_mail
      put :update_user_mail
      get :resign
      put :resign_confirm
      put :resign_do
      get :resign_complete
      get :facebook
      get :reg_key
      put :update_reg_key
      get :reg_key_complete
      get :google_auth
      get :check_register
    end
  end

  get "users/view_experience", :as => "user_view_experience"
  get "api/users/uuid", :to => "users#uuid", :as => "user_uuid"
  post "users/login/uuid", :to => "users#login_from_uuid", :as => "login_uuid"
  get "users/session/check",:to => "users#check_session", :as => "check_session"
  
  get "business_cards/autocomplete_business_card_lastname", :to => "business_cards#autocomplete_business_card_lastname", :as => "autocomplete_business_card_lastname"
  get "business_cards/autocomplete_business_card_lastname_kana", :to => "business_cards#autocomplete_business_card_lastname_kana", :as => "autocomplete_business_card_lastname_kana"
  get "business_cards/autocomplete_business_card_firstname", :to => "business_cards#autocomplete_business_card_firstname", :as => "autocomplete_business_card_firstname"
  get "business_cards/autocomplete_business_card_firstname_kana", :to => "business_cards#autocomplete_business_card_firstname_kana", :as => "autocomplete_business_card_firstname_kana"

  resources :releases, :only => [:index, :show]
  get "mandators/autocomplete_mandator_lastname", :to => "mandators#autocomplete_mandator_lastname", :as => "autocomplete_mandator_lastname"
  get "mandators/autocomplete_mandator_lastname_kana", :to => "mandators#autocomplete_mandator_lastname_kana", :as => "autocomplete_mandator_lastname_kana"
  get "mandators/autocomplete_mandator_firstname", :to => "mandators#autocomplete_mandator_firstname", :as => "autocomplete_mandator_firstname"
  get "mandators/autocomplete_mandator_firstname_kana", :to => "mandators#autocomplete_mandator_firstname_kana", :as => "autocomplete_mandator_firstname_kana"

  resources :business_cards do
    post "search", :on => :collection
    get "csv", :on => :collection
    post "csv_upload", :on => :collection
  end

  get "about" , :to => "helps#about" , :as => "about"
  get "tutorial" , :to => "helps#tutorial" , :as => "tutorial"
  get "blog" , :to => "helps#blog" , :as => "blog"
  get "profile" , :to => "helps#profile" , :as => "profile"
#  get "direct" , :to => "helps#direct" , :as => "direct"
  get "transaction" , :to => "helps#transaction" , :as => "transaction"
  get "term" , :to => "helps#term" , :as => "term"
  # get "payment" , :to => "helps#payment" , :as => "payment"
  get "feature" , :to => "helps#feature" , :as => "feature"
  get "test404" , :to => "helps#test404"
  get "test500" , :to => "helps#test500"
  get "robots" , :to => "helps#robots"
  get "sitemap", :to => "helps#sitemap"
  get "registration_complete", :to => "helps#registration_complete"
  get "password_complete", :to => "helps#password_complete"
  get "resending_comfirmation_complete", :to => "helps#resending_comfirmation_complete"
  get "recomfirmation_complete", :to => "helps#recomfirmation_complete"
  get "contact_complete", :to => "helps#contact_complete"
  get "tour" , :to => "helps#tour" , :as => "tour"

  get "home", :to => "home#index" , :as => "home"
  resources :oreno, :only => [:index]
  resources :restaurants, :only => [:index, :show] do
    collection do
      get :search, to: "restaurants_search#result"
    end

    member do
      post "featured"
      get "featured"
      patch "featured"
      get "map"
      get "seat"
      get "omotenashi"
      get "secret_seat"
      get "dining_out"
      get "draw"
      patch "draw_create"
      get "draw_complete"
      post "append"
      get "waiting"
      patch "waiting_create"
      get "waiting_complete"
    end
    collection do
      get "reservation_status"
      get "today"
    end
  end
  resources :restaurant_courses, :only => [:index, :show] do
  end
  get "restaurant/list", to: "restaurants#search_language", as: "search_language"
  get "restaurants/:id/:date", :to => "restaurants#show", :as => "restaurant_show_date"
  get "restaurants/:id/map" , :to => "restaurants#map" , :as => "restaurant_map"
  get "restaurants/:id/image_big" => "restaurants#image_big"  , :as => "restaurant_image_big"
  get "restaurants/:id/image_small" => "restaurants#image_small"  , :as => "restaurant_image_small"
  get "search/:date" , :to => "restaurants#search" , :as => "search"
  get "search/:date(/:time_type)" , :to => "restaurants#search", :as => "search_detail"
  get "search_features"  , :to => "restaurants#search_features", :as => "search_features"

  get "reservations/:id/cancel" , :to => "reservations#cancel"  , :as => "reservation_cancel"
  post "reservations/notice"

  #match "/auth/:provider/callback" => "sessions#create"
  #match "/signout" => "sessions#destroy", :as => :signout

  get "pictures/:id/thumbnail" ,:to => "pictures#thumbnail", :as => "thumbnail"
  get "pictures/:id/middle" ,:to => "pictures#middle", :as => "middle"
  get "pictures/:id/original" ,:to => "pictures#original", :as => "original"

  get "topics/index"
  post "topics/update"
  get "topics/:id/show" , :to => "topics#show" , :as => "topic"

  get "restaurant_templates/:id/:t/get_template", :to => "restaurant_templates#get_template"

  resources :featured_restaurants
  resources :update_histories
  resources :coupons
  resources :invites
  resources :opinions
  resources :calendars

  namespace :api do
    resources :areas
    resources :categories
    resources :restaurants
    resources :restaurant_courses
    resources :restaurant_features
    resources :featured_restaurants do
      collection do
        put 'delete'
      end
    end
    resources :seats do
      collection do
        put 'delete_seats'
        put 'recover_seats'
        get 'get_full_seats'
      end
    end
    resources :business_cards
    resources :reservations do
      collection do
        post 'add_companions'
        post 'some_action'
        get 'some_action'
        get 'complete'
        get 'get_payment_method_ids'
        get 'get_coupons'
      end
    end
    resources :users do
      collection do
        get 'credit_cards'
        put 'update_user_append'
        put 'update_user_mail'
        get 'user_mail'
        get 'user_anniversaries'
        put 'update_user_anniversaries'
        put 'delete_user_anniversary'
        put 'update_reg_key'
        get 'reg_key_complete'
        get 'invitation_code'
      end
    end
    devise_for :users
    post 'users/auth_facebook'
    post 'users/auth_line'

    namespace :owner do
      resource :sessions, only: [ :create, :destroy ]
      get 'sessions/uuid' => 'sessions#uuid', :as => 'uuid'
      post 'sessions/login_from_uuid'
      get 'sessions/check' => 'sessions#check_session', :as => 'check_session'
      resources :users, only: [ :index ]
      resources :utils do
        collection do
          get :get_notification_date
        end
      end
      resource :reservations do
        collection do
          get :no_charge_reservation_list
          post :charge
        end
      end
      resource :restaurants do
        collection do
          get :get_info
        end
      end
    end
  end

  get "admin/login", :to => "admin/login#index", :as => "admin/login"
  get "admin/logout", :to => "admin/login#logout"
  post "admin/login/login"

  get "admin", :to => "admin/restaurants#index", :as => "admin_top"
  namespace :admin do
    resources :concierge_questions do
      collection do
        get :csv
      end
      member do
        post :temp
        patch :change
      end
    end
    resources :categories
    resources :releases
    resources :receipts do
      collection do
        get 'monthly/:date', :to => "receipts#monthly", :as => "monthly"
        get 'restaurant/:date/:restaurant_id', :to => "receipts#restaurant", :as => "restaurant"
        post 'bank_transfer/:date', :to => "receipts#bank_transfer", :as => "bank_transfer"
        post :demand
      end
    end
    resources :bank_transfers do
      collection do
        get 'monthly/:date', :to => "bank_transfers#monthly", :as => "monthly"
      end
    end

    get "restaurants/search_station", :to => "restaurants#search_station", :as => "search_station"
    get "restaurants/search_recommend", :to => "restaurants#search_recommend", :as => "search_recommend"
    get "restaurants/get_city", :to => "restaurants#get_city", :as => "get_city"
    get "restaurants/get_town", :to => "restaurants#get_town", :as => "get_town"
    get "restaurants/:id/image_small" => "restaurants#image_small"  , :as => "restaurant_image_small"
    get "restaurants/:id/recoupd", :to => "restaurants#recoupd", :as => "recoupd_restaurants"
    get "resraurants/:id/reopen", :to => "restaurants#reopen", :as => "reopen_restaurant"
    get "restaurants/:id/refresh", :to => "restaurants#refresh", :as => "refresh_restaurant"
    resources :restaurants do
      resource :restaurant_account, :except => [:create, :new]
      resources :restaurant_answers, :as => "answers", :path => "answers", :only => [:index, :create, :destroy]
      resources :restaurant_courses do
        resources :restaurant_course_english_contents
      end
      resources :restaurant_informations
      resources :seat_destroy_settings
      resources :restaurant_english_contents
      member do
        get 'higher' => 'restaurants#move_order_higher', :as => 'higher'
        get 'lower' => 'restaurants#move_order_lower', :as => 'lower'
        get 'top' => 'restaurants#move_order_top', :as => 'top'
        get 'bottom' => 'restaurants#move_order_bottom', :as => 'bottom'
        post 'move' => 'restaurants#move_position', :as => 'move'
      end
    end

    put "reservations/fix", :to => "reservations#fix", :as => "reservation_fix"
    put "reservations/decline", :to => "reservations#decline", :as => "reservation_decline"
    put "reservations/cancel", :to => "reservations#cancel", :as => "reservation_cancel"
    get "reservations/search_user", :to => "reservations#search_user", :as => "reservation_search_user"
    get "reservations/search_business_card", :to => "reservations#search_business_card", :as => "reservation_search_business_card"
    get "reservations/search_mandator", :to => "reservations#search_mandator", :as => "reservation_search_mandator"
    get "reservations/get_seats", :to => "reservations#get_seats", :as => "get_seats"
    get "reservations/get_courses", :to => "reservations#get_courses", :as => "get_courses"
    get "reservations/get_anniversaries", :to => "reservations#get_anniversaries", :as => "get_anniversaries"
    get "reservations/get_payment_settings", :to => "reservations#get_payment_settings", :as => "get_payment_settings"
    get "reservations/result", :to => "reservations#result", :as => "reservations_result"
    get "reservations/:id/message", :to => "reservations#message", :as => "reservations_message"
    post "reservations/:id/message_create", :to => "reservations#message_create", :as => "reservations_message_create"
    delete "reservations/:reservation_id/message_destroy/:message_id", :to => "reservations#message_destroy", :as => "reservations_message_destroy"
    put "reservations/come", :to => "reservations#come", :as => "reservation_come"
    put "reservations/no_show", :to => "reservations#no_show", :as => "reservation_no_show"
    put "reservations/cancel_today", :to => "reservations#cancel_today", :as => "reservation_cancel_today"
    resources :reservations

    resources :restaurant_templates, only: [:index, :show]

    get "users/:id/resign", :to => "users#resign", :as => "user_resign"
    resources :users do
      member do
        get :coupon
        post :coupon
      end
    end

    resources :tracking_urls

    get "seats/all_index", :to => "seats#all_index", :as => "all_seats"
    get "seats/:id/new", :to => "seats#new", :as => "new_with_restaurant_seat"
    get "seats/:id/index", :to => "seats#index", :as => "seats_with_restaurant_seat"
    get "seats/:id/notification", :to => "seats#notification", :as => "notification_seats"
    get "seats/search_restaurant", :to => "seats#search_restaurant", :as => "search_restaurant"
    get "seats/back", :to => "seats#back", :as => "back_seat"
    resources :seats do
      collection do
        get "destroy_some", to: "seats#destroy_some", as: "destroy_some"
        post "multi_create"
      end
      member do
        get "change_notification_status/:status", to: "seats#change_notification_status", as: "change_notification_status"
      end
      resources :restaurant_draws do
        member do
          get :win
          get :lose
        end
        collection do
          get :send_lose_mail
        end
      end
      resources :secret_seat_settings do
        collection do
          get :sendmail
        end
      end
    end

    resources :restaurants do
      resources :restaurant_holidays do
        collection do
          get :edit_temporary
          get :get_tmp_closing_date
          get :save_tmp_closing_date
          get :check_tmp_closing_date
          get :get_restaurant_holidays
        end
      end
      resources :restaurant_close_settings do
        collection do
          get :get_closing_date
          get :save_closing_date
        end
      end
      resources :waitings do
        member do
          post :sendmail
        end
      end
    end

    get "seat_configs/:id/new", :to => "seat_configs#new", :as => "new_with_seat_config"
    get "seat_configs/:id/index", :to => "seat_configs#index", :as => "seat_configs_with_seat_config"
    resources :seat_configs

    get "owner_users/search_own_restaurant", :to => "owner_users#search_own_restaurants", :as => "owner_search_restaurants"
    resources :owner_users

    resources :restaurant_questions do
      member do
        get 'higher' => 'restaurant_questions#move_order_higher', :as => 'higher'
        get 'lower' => 'restaurant_questions#move_order_lower', :as => 'lower'
      end
    end

    resources :restaurant_rate_sets, :except => [:index, :destory]

    resources :update_histories

    resources :properties

    resources :banners do
      member do
        get 'heigher' => 'banners#move_order_higher', :as => 'higher'
        get 'lower'   => 'banners#move_order_lower',  :as => 'lower'
      end
    end

    resources :questionnaires
    resources :manuals
    resources :sn_disabled_restaurants do
      collection do
        get :search
        post :add
        post :delete
      end
    end
    resources :sn_restaurant_settings do
      collection do
        get :search
      end
    end
    resources :sn_analyzes
    resources :sn_dashboards

    resources :campaigns
    resources :coupons
    resources :demands do
      collection do
        get :complete
      end
    end
    resources :opinions
  end

  namespace :owner do
    root :to => "login#index"
    post "login", :to => "login#login"
    get "login", :to => "login#index"
    get "logout", :to => "login#logout"

    resources :restaurants do
      member do
        get :switch
      end
      resources :receipts do
        collection do
          get 'restaurant/:date/:restaurant_id', :to => "receipts#restaurant", :as => "restaurant"
          get 'bank_transfer/:date', :to => 'receipts#bank_transfer', :as => "bank_transfer"
        end
      end
      resources :seats do
        collection do
          get "destroy_some", to: "seats#destroy_some", as: "destroy_some"
        end
      end
      collection do
        get :search_station
        get :get_city
        get :get_town
      end
      get :image_small
      resources :reservations do
        member do
          post :fix
          post :decline
          post :cancel
          post :cancel_fix
          get :receipts
          get :charge
          patch :charge_fix
          post :charge_cancel
          #post 'charge_cancel/:payment_id', to: 'reservations#charge_cancel', as: 'charge_cancel'
          post :calc_total_amount
          put :come
          put :no_show
          put :cancel_today
          put :confirm_cancel_fee
          post :check
        end
      end
      resources :questionnaires
      resources :guest_reservations do
        collection do
          post :block
          post :change_seat
          post :combine_seat
          post :seat_list_for_change_date
          get 'index(.:format)', to: 'guest_reservations#index'
          post 'create(.:format)', to: 'guest_reservations#create'
        end
        member do
          post :fix
          post :change_date
          get :change_date
          get :cancel
        end
      end
      resources :restaurant_seats do
        member do
          get 'higher'
          get 'lower'
          post 'move'
        end
        collection do
          get 'index(.:format)', to: 'restaurant_seats#index'
        end
      end
      resources :receptions do
        collection  do
          post :seat_list
          post :memo_update
          get  :memo_update
          get  :memo_load
          post :confirm
        end
      end
      resources :restaurant_timetables do
        collection do
          get 'index(.:format)', to: 'restaurant_timetables#index'
        end
      end
      resources :users do
        member do
          get :get_image
        end
      end
      resources :guests do
        member do
          get :get_image
          get :info
        end
        collection do
          get 'index(.:format)', to: 'guests#index'
          post 'create(.:format)', to: 'guests#create'
        end
      end
      resources :guest_categories do
        member do
          get 'higher'
          get 'lower'
          post 'move'
        end
        collection do
          get 'index(.:format)', to: 'guest_categories#index'
        end
      end
      resources :custom_fields do
        member do
          get 'higher'
          get 'lower'
          post 'move'
        end
      end
      resources :restaurant_drink_categories
      resources :restaurant_drinks do
        collection do
          get :autocomplete_restaurant_drink_name
          post :simple_create
          get :bulk_new
          post :bulk_create
          get :get_drinks
        end
        member do
          get 'higher'
          get 'lower'
          post 'move'
        end
      end
      resources :restaurant_dishes do
        collection do
          get :autocomplete_restaurant_dish_name
          post :simple_create
          get :bulk_new
          post :bulk_create
        end
      end
      resources :restaurant_pay_methods do
        collection do
          get 'index(.:format)', to: 'restaurant_pay_methods#index'
        end
      end
      resources :restaurant_memo_tags do
        collection do
          get :bulk_new
          post :bulk_create
        end
      end
      resources :restaurant_receptionists do
        collection do
          get "index(.:format)", to: "restaurant_receptionists#index"
        end
      end
      get "restaurant_courses/get_template", :to => "restaurant_courses#get_template", :as => "get_template_restaurant_course"
      resources :restaurant_courses do
        member do
          get :choose
          get 'higher'
          get 'lower'
          post 'move'
        end
        collection do
          get :search_dish
          get 'index(.:format)', to: 'restaurant_courses#index'
        end
      end
      resources :restaurant_informations do
        member do
          get :deliver
        end
      end
      resources :restaurant_templates
      resources :restaurant_holidays do
        member do
          get :edit_regular
        end
        collection do
          get :new_regular
          get :edit_temporary
          get :get_tmp_closing_date
          get :get_restaurant_holidays
          get :save_tmp_closing_date
          get :check_tmp_closing_date
        end
      end
      resources :seat_configs
    end
  end

  mount Webhookr::Engine => "/webhook", :as => "webhookr"

  root :to => "home#index"

  get '*path', controller: 'application', action: 'render_404'
  #match "*not_found" => "application#render_404"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
