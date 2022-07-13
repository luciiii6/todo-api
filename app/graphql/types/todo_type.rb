# frozen_string_literal: true

module Types
  class TodoType < Types::BaseObject
    field :id, ID, null: false
    field :completed, Boolean
    field :title, String, null: false
    field :url, String
    field :order, Integer
  end
end
