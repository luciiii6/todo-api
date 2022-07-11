# frozen_string_literal: true

class TodosController < ApplicationController
  def create
    verify_headers(request.headers)
    todo = Todo.create(title: validated_params_for_create[:title], completed: false,
                       order: validated_params_for_create[:order])
    todo.url = url_for(todo)
    todo.save!
    if request.headers['Accept'].include? 'application/json'
      render json: todo, status: :created
    else
      render xml: {todo: todo.attributes}, status: :created
    end

  rescue ActionController::ParameterMissing
    render json: { error: 'Content missing' }, status: 400
  end

  def index
    verify_headers(request.headers)

    data = Todo.all
    if request.headers['Accept'].include? 'application/json'
      render json: data, status: :ok
    else
      render xml: data.map(&:attributes), status: :ok
    end
  end

  def show
    todo = Todo.find_by!(id: params[:id])
    render json: todo, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def update
    todo = Todo.find_by!(id: params[:id])
    update_todo(todo, validated_params_for_update)

    render json: todo, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  rescue ActionController::ParameterMissing
    render json: { error: 'Todo not found' }, status: 400
  end

  def destroy
    todo = Todo.find_by!(id: params[:id])
    todo.destroy

    render json: Todo.all, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def destroy_all
    Todo.destroy_all
    render json: Todo.all, status: :ok
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed, :order)
  end

  def validated_params_for_create
    return todo_params if todo_params.key?('title') && todo_params['title'] != '' && !todo_params.key?('completed')
    return todo_params if todo_params['completed'] == true || todo_params['completed'] == false

    raise ActionController::ParameterMissing, 'Wrong parameters for request'
  end

  def validated_params_for_update
    if todo_params.empty? || todo_params[:completed].is_a?(String)
      raise ActionController::ParameterMissing,
            'Wrong parameters for request'
    end

    todo_params
  end

  def update_todo(todo, params)
    todo.title = params[:title] if params[:title]
    todo.completed = params[:completed] if params.key?(:completed)
    todo.order = params[:order] if params[:order]
    todo.save!
  end

  def verify_headers(headers)
    render status: :precondition_required if headers['Accept'].exclude?('application/json') &&
      headers['Accept'].exclude?('application/xml')
  end
end
