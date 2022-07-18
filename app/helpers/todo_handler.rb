# frozen_string_literal: true

class TodoHandler
  class << self
    include Rails.application.routes.url_helpers

    def create(validated_params)
      todo = Todo.create(title: validated_params['title'], completed: false,
                         order: validated_params['order'])
      todo.url = url_for(todo)
      todo.save!
      todo
    end

    def update(id, validated_params)
      todo = Todo.find(id)
      todo.update!(**validated_params)

      todo
    end
  end
end
