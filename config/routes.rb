Rails.application.routes.draw do
  resources :users
  resources :textbooks
  resources :notify_items

  resources :conversations do
    resources :messages
  end

  resources :users do
    resources :textbooks
  end

  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  get 'aws/:id/:ext' => 'textbooks#aws'
  delete 'delete_image/:id' => 'textbooks#delete_image'
  get 'get_delete_url/:id' => 'textbooks#get_delete_url'

  post 'firebase' => 'users#firebase'

  get 'search/:category/:input' => 'textbooks#search'

  get 'notify_results/:user_id' => 'notify_items#notify_results'
end
