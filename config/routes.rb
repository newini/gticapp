Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  #===================================================
  # Root path
  root 'static_pages#home'
  # Redirect root path
  #root to: redirect('/ja/home')


  #===================================================
  # Static pages
  match '/home', to: 'static_pages#home', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/ceo_message', to: 'static_pages#ceo_message', via: 'get'
  match '/organizer', to: 'static_pages#organizer', via: 'get'
  match '/media', to: 'static_pages#media', via: 'get'
  match '/our_sponsors', to: 'static_pages#our_sponsors', via: 'get'
  match '/contact_us', to: 'static_pages#contact_us', via: 'get'
  # Events
  match '/event_list', to: 'static_pages#event_list', via: 'get'
  match '/event_detail', to: 'static_pages#event_detail', via: 'get'
  match '/register_event_form', to: 'static_pages#register_event_form', via: 'post'
  match '/register_event_user', to: 'static_pages#register_event_user', via: 'post'
  match '/deregister_event', to: 'static_pages#deregister_event', via: 'post'
  match '/deregister_event_confirm', to: 'static_pages#deregister_event_confirm', via: 'get'
  match '/search_event', to: 'static_pages#search_event', via: 'get'
  match '/search_media_article', to: 'static_pages#search_media_article', via: 'get'


  #===================================================
  # For authentication
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    #passwords: 'users/passwords',
    #registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  # User page
  resources :users do
    collection do
      get :privacy_policy
    end
  end


  #===================================================
  # Staff only

  # Prefix 'admin'
  # Uncommend and use if need for future
  # https://makandracards.com/makandra/38773-rails-route-namespacing-in-different-flavors
  #scope path: 'admin' do

    resources :accounts

    resources :broadcasts do
      collection do
        get 'sent_list'
      end
      member do
        get 'show_sent'
        get :find_members
        get :search
        get :send_email
        get :broadcast_member_list
        post :add_emails
        post :delete_broadcast_member
        post :update_include_all_flg
        post :update_broadcast_member
        post :update_birth_month
        post :update_event_id
        post :update_include_gtic_flg
      end
    end

    resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :contacts do
      member do
        post 'update_response_completed'
      end
    end

    resources :events do
      collection do
        get :download
        get :search
        get :statistics
      end
      member do
        get :registed
        get :update_registed_member
        get :participants
        get :update_participants
        get :dotasan
        get :declined
        get :dotacan
        get :no_show
        get :waiting
        get :add_presenter
        get :add_as_presenter
        get :search_member
        get :statistics
        get :account
        get 'serve_file'
        get 'check_in'
        post :change_status
        post :change_role
        post :destroy_relationship
        post :switch_black_list_flg
        post :update_birthday
        post :create_member
        post 'upload_file'
        post 'set_bkg_image'
      end
    end

    resources :event_categories, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :images do
      collection do
        get :serve
      end
    end

    resources :manuals

    resources :media_articles do
      member do
        post :delete_file
        get :serve_file
      end
    end

    resources :members do
      collection do
        get :azsa_list
        get :no_show_list
        get :black_list
        get :category
        get :count
        get :search
        post :fill_alphabet_from_kanji_name
      end
      member do
        post 'upload_profile_picture'
      end
    end

    resources :places, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :presentations, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :relationships, only: [:create, :edit, :update, :destroy]
    resources :registers
    resources 'sponsors' do
      member do
        post 'upload_logo_image'
      end
    end
    resources :staffs

  #end # end of scope (prefix)

end
