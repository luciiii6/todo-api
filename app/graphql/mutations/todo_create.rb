# frozen_string_literal: true

module Mutations
  class TodoCreate < BaseMutation
    include ActionView::Helpers
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers

    description 'Creates a new todo'

    field :todo, Types::TodoType, null: false

    argument :todo_input, Types::TodoInputType, required: true

    def resolve(todo_input:)
      todo = Todo.create(title: todo_input[:title], completed: false)

      raise GraphQL::ExecutionError.new 'Error creating todo', extensions: todo.errors.to_hash unless todo.save

      todo.url = todo_url(todo)
      todo.save

      { todo: todo }
    end
  end
end
