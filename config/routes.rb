Rails.application.routes.draw do
  root 'static_pages#home'
  devise_for :users, 
    controllers: { confirmations: 'confirmations', registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks' }
  get '/about', to: 'static_pages#about'
  resources :posts, only: [:create]
end
