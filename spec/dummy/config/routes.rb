Rails.application.routes.draw do
  resources :users, only: %i[create]
  namespace :admin do
    resources :users, only: %i[create]
  end
end
