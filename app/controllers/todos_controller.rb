class TodosController < ApplicationController
  def create
    todo = Todo.create(content: validated_params[:content], completed: false)
    render action: "index", status: :created
  rescue ActionController::ParameterMissing
    render json: { error: "Content missing" }, status: 400
  end

  def index
    todos = Todo.all

    render json: {todos: todos}, status: :ok
  end

  def update
    pp params[:id]
    todo = Todo.find_by(id: params[:id])
    todo.content = validated_params[:content]
    todo.completed = validated_params[:completed]
    todo.save!

    render action: "index", status: :ok
  rescue
    render json: { error: "Todo not found" }, status: 404
  end

  private

  def todo_params
    params.require(:todo).permit(:content, :completed)
  end

  def validated_params
    return todo_params unless todo_params[:content] == "" &&
                              todo_params[:completed] != true &&
                              todo_params[:completed] != false
    raise ActionController::ParameterMissing.new("Parameter content is an empty string")
  end
end
