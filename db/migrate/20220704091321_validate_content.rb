# frozen_string_literal: true

class ValidateContent < ActiveRecord::Migration[7.0]
  def change
    change_column_null :todos, :content, null: false
  end
end
