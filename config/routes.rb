Rails.application.routes.draw do
  resources :users
  resources :textbooks
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
end
