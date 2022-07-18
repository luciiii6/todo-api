# frozen_string_literal: true

module Mutations
  class TodoUpdate < BaseMutation
    description 'Updates a todo by id'

    field :todo, Types::TodoType, null: false

    argument :id, ID, required: true
    argument :todo_input, Types::TodoInputType, required: true

    def resolve(id:, todo_input:)
      todo = ::Todo.find(id)
      TodoHandler.update_todo(todo, Validator.validated_params_for_update(todo_input.to_h.stringify_keys))

      { todo: todo }
    end
  end
end
