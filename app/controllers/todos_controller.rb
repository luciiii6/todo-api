# frozen_string_literal: true

require './app/presenters/todo_presenter'
require './app/helpers/todo_handler'
require './app/helpers/todo_validator'

class TodosController < ApplicationController
  def create
    params = parse_params(request)

    render_by_method(TodoHandler.create(TodoValidator.validate_params_for_create(params)), request.headers)
  rescue ActionController::ParameterMissing
    render json: { error: 'Content missing' }, status: 400
  end

  def index
    render_by_method(Todo.all, request.headers)
  end

  def show
    render json: TodoHandler.find(params[:id]), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def update
    body_parameters = parse_params(request)
    todo = TodoHandler.update(params[:id], TodoValidator.validate_params_for_update(body_parameters))

    render_by_method(todo, request.headers)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  rescue ActionController::ParameterMissing
    render json: { error: 'Todo not found' }, status: 400
  end

  def destroy
    TodoHandler.delete(params[:id])

    render json: {}, status: successful_status_code(request.headers)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def destroy_all
    TodoHandler.delete_all
    render json: {}, status: successful_status_code(request.headers)
  end

  private

  def todo_params
    params.require(:todo).permit(:id, :title, :completed, :order)
  end

  def successful_status_code(headers)
    return :created if headers['REQUEST_METHOD'] == 'POST'

    :ok
  end

  def render_by_method(data, headers)
    if headers['REQUEST_METHOD'] == 'GET'
      render_for_get(data, headers)
    else
      render_for_post_and_patch(data, headers)
    end
  end

  def render_for_post_and_patch(data, headers)
    if headers['Accept'].include?('application/xml')
      render xml: TodoPresenter.new(data).to_xml,
             status: successful_status_code(headers)
    else
      render json: { todo: TodoPresenter.new(data).to_h }, status: successful_status_code(headers)
    end
  end

  def render_for_get(data, headers)
    if headers['Accept'].include?('application/xml')

      render xml: data.map(&:attributes).collect { |elem|
                    TodoPresenter.new(elem).to_h
                  }.to_xml(root: 'todos', skip_types: true), status: successful_status_code(request.headers)
    else
      render json: { todos: data.collect do |elem|
        TodoPresenter.new(elem).to_h
      end }, status: successful_status_code(headers)
    end
  end

  def parse_params(request)
    return Hash.from_xml(request.raw_post)['todo'] if request.headers['CONTENT-TYPE'].include? 'application/xml'

    todo_params
  end
end
