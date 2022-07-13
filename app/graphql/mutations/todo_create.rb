# frozen_string_literal: true

module Mutations
  class TodoCreate < BaseMutation
    description "Creates a new todo"

    field :todo, Types::TodoType, null: false

    argument :todo_input, Types::TodoInputType, required: true

    def resolve(todo_input:)
      todo = Todo.create(**todo_input)

      raise GraphQL::ExecutionError.new "Error creating todo", extensions: todo.errors.to_hash unless todo.save
      todo.url = "test"
      todo.save

      { todo: todo }
    end
  end
end
