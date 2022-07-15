# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :todos, resolver: Resolvers::Todos do
      argument :limit, Integer, default_value: 20, prepare: ->(limit, _ctx) { limit }
    end

    field :todos_connection, Types::TodosConnection, null: false

    def todos_connection(**_args)
      Todo.all
    end
  end
end
