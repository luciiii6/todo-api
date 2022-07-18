# frozen_string_literal: true

require './app/helpers/todo_handler'
require './app/helpers/todo_validator'

module Mutations
  class TodoCreate < BaseMutation
    description 'Creates a new todo'

    field :todo, Types::TodoType, null: false

    argument :todo_input, Types::TodoInputType, required: true

    def resolve(todo_input:)
      todo = TodoHandler.create(TodoValidator.validate_params_for_create(todo_input.to_h.stringify_keys))

      { todo: todo }
    end
  end
end
