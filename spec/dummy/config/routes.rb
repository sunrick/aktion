Rails.application.routes.draw do
  resources :users, only: [:create]
  namespace :admin do
    resources :users, only: [:create]
  end
end
