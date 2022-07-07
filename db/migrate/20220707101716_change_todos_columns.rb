class ChangeTodosColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :todos, :content, :string
    add_column :todos, :title, :string, null: false
    add_column :todos, :url, :string
  end
end
