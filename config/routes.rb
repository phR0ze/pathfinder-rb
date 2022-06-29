Rails.application.routes.draw do
  resources :users do
    resources :points
    resources :rewards
  end
  resources :history
  resources :categories
end
