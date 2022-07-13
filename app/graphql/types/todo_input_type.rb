# frozen_string_literal: true

module Types
  class TodoInputType < Types::BaseInputObject
    # argument :completed, Boolean, required: false
    argument :title, String, required: true
    # argument :order, Integer, required: false
  end
end
