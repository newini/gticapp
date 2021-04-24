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
  match '/search_event', to: 'static_pages#search_event', via: 'get'
  match '/ceo_message', to: 'static_pages#ceo_message', via: 'get'
  match '/organizer', to: 'static_pages#organizer', via: 'get'
  match '/media', to: 'static_pages#media', via: 'get'
  match '/schedule', to: 'static_pages#schedule', via: 'get'
  match '/contact_us', to: 'static_pages#contact_us', via: 'get'
  # Events
  match '/event_list', to: 'static_pages#event_list', via: 'get'
  match '/event_detail', to: 'static_pages#event_detail', via: 'get'
  match '/register_event', to: 'static_pages#register_event', via: 'post'
  match '/deregister_event', to: 'static_pages#deregister_event', via: 'get'


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
  #end

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

  resources :staffs

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

  resources :media_articles do
    member do
      post :delete_file
      get :serve_file
    end
  end

  resources :relationships, only: [:create, :edit, :update, :destroy]
  resources :places, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :presentations, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :event_categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :accounts
  resources :registers

  # Manuals
  resources :manuals

  # Treat attachment file
  resources :images do
    collection do
      get :serve
    end
  end

  resources :contacts do
    member do
      post 'update_response_completed'
    end
  end



end
