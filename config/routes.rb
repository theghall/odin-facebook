Rails.application.routes.draw do
  root 'static_pages#home'
  devise_for :users, 
    controllers: { confirmations: 'confirmations', registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks' }
  get '/profile/:id', to: 'user#show', as: :profile
  get '/profiles', to: 'user#index', as: :profiles
  get '/about', to: 'static_pages#about'
  resources :posts, only: [:create] do
    resources :worthies, only: [:create]
    resources :comments, only: [:create]
  end
  resources :worthies, only: [:destroy]
  resources :comrades, only: [:index, :destroy]
  resources :comrade_requests, only: [:index, :create, :update, :destroy]
end
