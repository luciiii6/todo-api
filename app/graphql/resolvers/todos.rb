# frozen_string_literal: true

module Resolvers
  class Todos < Resolvers::Base
    type [Types::TodoType], null: false

    def resolve
      Todo.all
    end
  end
end
