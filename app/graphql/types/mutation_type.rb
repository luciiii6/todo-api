# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :todo_delete, mutation: Mutations::TodoDelete
    field :todo_update, mutation: Mutations::TodoUpdate
    field :todo_create, mutation: Mutations::TodoCreate
  end
end
