# frozen_string_literal: true

module Types
  class TodosEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::TodoType)
  end

  class TodosConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false
    def total_count
      object.nodes.size
    end
    edge_type(TodosEdgeType)
  end
end
