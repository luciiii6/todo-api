# frozen_string_literal: true

module Mutations
  class TodoUpdate < BaseMutation
    description 'Updates a todo by id'

    field :todo, Types::TodoType, null: false

    argument :id, ID, required: true
    argument :todo_input, Types::TodoInputType, required: true

    def resolve(id:, todo_input:)
      todo = ::Todo.find(id)
      unless todo.update(**todo_input)
        raise GraphQL::ExecutionError.new 'Error updating todo', extensions: todo.errors.to_hash
      end

      { todo: todo }
    end
  end
end
