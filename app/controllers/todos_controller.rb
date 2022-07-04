class TodosController < ApplicationController
  def create
    todo = Todo.create(content: validated_params[:content], completed: false)
    render action: "index", status: :created
  rescue ActionController::ParameterMissing
    render json: { error: "Content missing" }, status: 400
  end

  private

  def todo_params
    params.require(:todo).permit(:content)
  end

  def validated_params
    return todo_params unless todo_params[:content] == ""
    raise ActionController::ParameterMissing.new("Parameter content is an empty string")
  end
end
