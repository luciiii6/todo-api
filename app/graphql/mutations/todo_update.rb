# frozen_string_literal: true

module Mutations
  class TodoUpdate < BaseMutation
    description 'Updates a todo by id'

    field :todo, Types::TodoType, null: false

    argument :id, ID, required: true
    argument :todo_input, Types::TodoInputType, required: true

    def resolve(id:, todo_input:)
      todo = TodoHandler.update(id, TodoValidator.validate_params_for_update(todo_input.to_h.stringify_keys))

      { todo: todo }
    end
  end
end
