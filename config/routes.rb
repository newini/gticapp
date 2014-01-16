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
  root 'members#index'
end
