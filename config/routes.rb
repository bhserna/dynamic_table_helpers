Rails.application.routes.draw do
  root to: redirect("/products")
  resources :products, only: [:index]
  resources :contacts, only: [:index]
end
