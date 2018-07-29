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

  get 'aws/:id/:ext' => 'textbooks#aws'
  get 'get_delete_url/:id' => 'textbooks#get_delete_url'

  post 'firebase' => 'users#firebase'
end
