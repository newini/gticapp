Gticapp::Application.routes.draw do
  resources :members do
    collection { post :import }
    member { get :participated }
  end
  resources :events do
    collection { post :import }
    member { post :import_participants }
    member { get :participant }
    member { post :change_status }
    resources :invitations
    member { get :invited }
    member { get :invite }
    member { post :change_connection }
    member { post :change_all_connection }
  end
  resources :relationships, only: [:create, :destroy]
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/signup', to: 'users#new', via: 'get'
  match '/home', to: 'static_pages#home', via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_invitation', as: 'send_invitation',via: 'get'
  match '/events/:event_id/send_invitation', to: 'events#send_email', via: 'post'

  root 'static_pages#home'
end
