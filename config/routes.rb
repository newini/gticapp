Gticapp::Application.routes.draw do
  resources :members do
    collection do
      post :import
      get :management
      post :update_information
      get :search
    end
  end
  resources :events do
    member do
      get :invite
      get :waiting
      get :maybe
      get :invited
      get :registed
      get :participants
      get :declined
      get :no_show
      get :new_member
      get :search
      get :update_maybe_member
      get :update_registed_member
      get :update_participants
      get :statistics
      post :change_status
      post :switch_black_list_flg
      post :change_all_waiting_status
      post :create_member
      post :import_participants
      post :import_registed_members
      post :switch_presenter_flg
      post :switch_guest_flg
      post :update_facebook
      post :update_presentation
    end
    resources :invitations
    collection { 
      post :import
      get :statistics
    }
  end
  resources :relationships, only: [:create, :destroy]
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :places, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :presentations, only: [:create, :update, :destroy]
  resources :event_categories, only: [:index, :new, :create, :edit, :update, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signup', to: 'users#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/home', to: 'static_pages#home', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/presenter', to: 'static_pages#presenter', via: 'get'
  match '/organizer', to: 'static_pages#organizer', via: 'get'
  match '/media', to: 'static_pages#media', via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_invitation', as: 'send_invitation',via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_email', via: 'post'
  #omniauth
  match '/auth/:provider/callback', to: 'sessions#create', via: 'get'


  root 'static_pages#home'
end
