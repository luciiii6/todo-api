# frozen_string_literal: true

module Resolvers
  class Todos < Resolvers::Base
    type [Types::TodoType], null: false

    def resolve(**params)
      Todo.all.limit(params.fetch(:limit))
    end
  end
end
