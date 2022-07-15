# frozen_string_literal: true

class TodoPresenter
  def initialize(todo)
    @todo = todo.slice('title', 'url', 'completed', 'order')
  end

  def to_xml
    @todo.to_xml(root: 'todo')
  end
  
  def to_h
    @todo
  end
end
