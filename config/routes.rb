Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # For authentication
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  # User page
  resources :users

  resources :members do
    collection do
      get :management
      get :search
      get :count
      get :no_show_list
      get :black_list
      get :category
      get :participated_events_list
      get :search_participated
      get :azsa_list
      post :import
      post :update_information
      post :name_to_alphabet
      post :convert_fb_str_to_id
      post :update_azsa
      post :update_contributor
      post :update_past_presenter
      post :update_black_list
    end
  end

  resources :events do
    collection do
      get :download
      get :search_event
    end
    member do
      get :invite
      get :waiting
      get :maybe
      get :registed
      get :participants
      get :dotasan
      get :declined
      get :dotacan
      get :no_show
      get :search
      get :update_maybe_member
      get :update_registed_member
      get :update_participants
      get :statistics
      get :account
      get :registed_list
      post :change_status
      post :destroy_relationship
      post :switch_black_list_flg
      post :change_all_waiting_status
      post :create_member
      post :import_participants
      post :import_participants_from_xlsx
      post :import_registed_members
      post :import_from_questionnaire
      post :change_role
      post :update_facebook
      post :update_birthday
      post :update_black_list
    end
    collection {
      get :statistics
      post :import
    }
  end

  resources :staffs do
    collection do
      post :update_active
      post :update_admin
      post :update_staffs
    end
  end

  resources :invitations do
    collection do
      get 'view_sent_emails' => 'invitations#view_sent_emails', as: :view_sent_emails
    end
    member do
      get :find_members
      get :search
      get :send_email
      get :view_member_invitation
      post :add_emails
      post :delete_member_invitation
      post :update_include_all_flg
      post :update_member_invitation
      post :update_birth_month
      post :update_event_id
      post :update_include_gtic_flg
    end
  end

  resources :media_articles do
    member do
      post :delete_file_path
    end
  end

  # Gmail
  get '/gmails/redirect'
  get '/gmails/callback'
  get '/gmails/getmail'

  resources :relationships, only: [:create, :edit, :update, :destroy]
  #resources :sessions, only: [:new, :create, :destroy]
  resources :places, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :presentations, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :event_categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :accounts
  resources :registers


  #match '/signin', to: 'sessions#new', via: 'get'
  #match '/signup', to: 'staffs#new', via: 'get'
  #match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/home', to: 'static_pages#home', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/presenter', to: 'static_pages#presenter', via: 'get'
  match '/search_event', to: 'static_pages#search_event', via: 'get'
  match '/ceo_message', to: 'static_pages#ceo_message', via: 'get'
  match '/organizer', to: 'static_pages#organizer', via: 'get'
  match '/media', to: 'static_pages#media', via: 'get'
  match '/schedule', to: 'static_pages#schedule', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'

  #omniauth
  #match '/auth/:provider/callback', to: 'sessions#create', via: 'get'

  root 'static_pages#home'

  #manuals
  get 'manuals/index'
  get 'manuals/add_event'
  get 'manuals/add_presentation'

end
