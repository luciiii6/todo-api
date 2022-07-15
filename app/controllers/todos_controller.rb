# frozen_string_literal: true

require './app/presenters/todo_presenter'

class TodosController < ApplicationController
  def create
    params = parse_params(request)

    render_by_method(create_todo(validated_params_for_create(params)), request.headers)
  rescue ActionController::ParameterMissing
    render json: { error: 'Content missing' }, status: 400
  end

  def index
    render_by_method(Todo.all, request.headers)
  end

  def show
    todo = Todo.find_by!(id: params[:id])
    render json: todo, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def update
    todo = Todo.find_by!(id: params[:id])
    params = parse_params(request)
    update_todo(todo, validated_params_for_update(params))

    render_by_method(todo, request.headers)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  rescue ActionController::ParameterMissing
    render json: { error: 'Todo not found' }, status: 400
  end

  def destroy
    todo = Todo.find_by!(id: params[:id])
    todo.destroy

    render json: {}, status: successful_status_code(request.headers)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: 404
  end

  def destroy_all
    Todo.destroy_all
    render json: {}, status: successful_status_code(request.headers)
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed, :order)
  end

  def validated_params_for_create(params)
    return params if params.key?('title') && params['title'] != '' && !params.key?('completed')
    return params if params['completed'] == true || params['completed'] == false

    raise ActionController::ParameterMissing, 'Wrong parameters for request'
  end

  def validated_params_for_update(params)
    if params.empty? || params['completed'].is_a?(String)
      raise ActionController::ParameterMissing,
            'Wrong parameters for request'
    end

    params
  end

  def create_todo(validated_params)
    todo = Todo.create(title: validated_params['title'], completed: false,
                       order: validated_params['order'])
    todo.url = url_for(todo)
    todo.save!
    todo
  end

  def update_todo(todo, params)
    todo.title = params['title'] if params['title']
    todo.completed = params['completed'] if params.key?('completed')
    todo.order = params['order'] if params['order']
    todo.save!
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
      render json: { todos: data }, status: successful_status_code(headers)
    end
  end

  def parse_params(request)
    return Hash.from_xml(request.raw_post)['hash']['todo'] if request.headers['CONTENT-TYPE'].include? 'application/xml'

    todo_params
  end
end
