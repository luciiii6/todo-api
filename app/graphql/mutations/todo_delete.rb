# frozen_string_literal: true

module Mutations
  class TodoDelete < BaseMutation
    description 'Deletes a todo by ID'

    field :todo, Types::TodoType, null: false

    argument :id, ID, required: true

    def resolve(id:)
      todo = ::Todo.find(id)
      raise GraphQL::ExecutionError.new 'Error deleting todo', extensions: todo.errors.to_hash unless todo.destroy

      { todo: todo }
    end
  end
end
