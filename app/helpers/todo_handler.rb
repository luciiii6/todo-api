# frozen_string_literal: true

class TodoHandler
  class << self
    include Rails.application.routes.url_helpers

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
  end
end
