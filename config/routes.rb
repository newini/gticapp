Gticapp::Application.routes.draw do
  resources :members do
    collection do
      post :import
      get :management
      post :update_information
    end
  end
  resources :events do
    member do
      get :invite
      get :waiting
      get :invited
      get :registed
      get :participants
      get :canceled
      get :no_show
      get :new_member
      get :search
      post :change_status
      post :switch_black_list_flg
      post :change_all_waiting_status
      post :create_member
      post :import_participants
      post :import_registed_members
      post :switch_presenter_flg
      post :switch_guest_flg
      post :update_facebook
    end
    resources :invitations
    collection { 
      post :import
    }
  end
  resources :relationships, only: [:create, :destroy]
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signup', to: 'users#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/home', to: 'static_pages#home', via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_invitation', as: 'send_invitation',via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_email', via: 'post'
  #omniauth
  match '/auth/:provider/callback', to: 'sessions#create', via: 'get'

  root 'static_pages#home'
end
