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
  end
  resources :relationships, only: [:create, :destroy]
  root 'members#index'
end
