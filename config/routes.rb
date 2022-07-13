# frozen_string_literal: true

Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  resources :todos
  match 'todos', to: 'todos#destroy_all', via: :delete
  match '/', to: 'todos#index', via: :get
  match '/', to: 'todos#create', via: :post
  match '/', to: 'todos#destroy_all', via: :delete
end
