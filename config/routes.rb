Rails.application.routes.draw do
  resources :users
  resources :textbooks

  resources :conversations do
    resources :messages
  end

  resources :users do
    resources :textbooks
  end

  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
end
