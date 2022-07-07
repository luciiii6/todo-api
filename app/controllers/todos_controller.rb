# frozen_string_literal: true

class TodosController < ApplicationController
  def create
    Todo.create(title: validated_params[:title], completed: false)
    render action: 'index', status: :created
  rescue ActionController::ParameterMissing
    render json: { error: 'Content missing' }, status: 400
  end

  def index
    todos = Todo.all

    render json: { todos: todos }, status: :ok
  end

  def update
    todo = Todo.find_by!(id: params[:id])
    todo.title = validated_params[:title] if validated_params[:title]
    todo.completed = validated_params[:completed]
    todo.save!

    render action: 'index', status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  rescue ActionController::ParameterMissing
    render json: { error: 'Todo not found' }, status: 400
  end

  def destroy
    todo = Todo.find_by!(id: params[:id])
    todo.destroy

    render json: {}, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def destroy_all
    Todo.destroy_all
    render json: {}, status: :ok
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end

  def validated_params
    return todo_params if todo_params.key?('title') && todo_params['title'] != '' && !todo_params.key?('completed')
    return todo_params if todo_params['completed'] == 'true' || todo_params['completed'] == 'false'

    raise ActionController::ParameterMissing, 'Wrong parameters for request'
  end
end
