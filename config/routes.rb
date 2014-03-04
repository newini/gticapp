Gticapp::Application.routes.draw do
  resources :members do
    collection { post :import }
    collection { get :management }
    collection { post :update_information }
  end
  resources :events do
    collection { post :import }
    member { post :import_participants }
    member { post :import_registed_members }
    member { post :swich_presenter_flg }
    member { post :update_facebook }
    resources :invitations
    member { get :invite }
    member { get :waiting }
    member { get :invited }
    member { get :registed }
    member { get :participants }
    member { get :canceled }
    member { get :no_show }
    member { post :change_status }
    member { post :swich_black_list_flg }
    member { post :change_all_waiting_status }
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
