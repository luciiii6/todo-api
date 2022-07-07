# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :todos
  match 'todos', to: 'todos#destroy_all', via: :delete
  match '/', to: 'todos#index', via: :get
  match '/', to: 'todos#create', via: :post
  match '/', to: 'todos#update', via: :patch
  match '/', to: 'todos#destroy_all', via: :delete
end
