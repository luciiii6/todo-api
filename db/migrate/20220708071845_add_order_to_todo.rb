class AddOrderToTodo < ActiveRecord::Migration[7.0]
  def change
    add_column :todos, :order, :integer
  end
end