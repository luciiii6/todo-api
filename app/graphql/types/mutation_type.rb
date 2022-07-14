# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :todo_create, mutation: Mutations::TodoCreate
  end
end
