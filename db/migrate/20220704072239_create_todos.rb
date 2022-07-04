# frozen_string_literal: true

class CreateTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.string :content, null: false
      t.boolean :completed

      t.timestamps
    end
  end
end
