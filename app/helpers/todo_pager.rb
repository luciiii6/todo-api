# frozen_string_literal: true

class TodoPager
  DEFAULT_SIZE = 20

  class << self
    def get_page(page_details)
      return { todos: Todo.all.collect { |todo| TodoPresenter.new(todo).to_h }, metadata: {} } unless page_details

      page_details['size'] = DEFAULT_SIZE unless page_details.key?('size')
      if PageParametersValidator.valid?(page_details)
        data = get_data(page_details)
        metadata = get_metadata(data, page_details)
      end

      {
        todos: data.collect { |todo| TodoPresenter.new(todo).to_h },
        metadata: metadata
      }
    end

    private

    def get_data(page_details)
      id = id(page_details)
      data = get_todos(id, page_details)

      raise PageParametersValidator::PageError, 'Non existent items this way' if data.empty?

      data
    end

    def get_metadata(todos, _page_details)
      {
        firstCursor: CursorEncoder.encode(todos[0].id.to_s),
        lastCursor: CursorEncoder.encode(todos[-1].id.to_s),
        hasNextPage: next_page?(todos),
        hasPreviousPage: previous_page?(todos)
      }
    end

    def id(page_details)
      return CursorEncoder.decode(page_details['after']) if page_details.key?('after')
      return CursorEncoder.decode(page_details['before']) if page_details.key?('before')
    end

    def next_page?(todos)
      return true if Todo.where('created_at < ?', todos[-1][:created_at]).first

      false
    end

    def previous_page?(todos)
      return true if Todo.where('created_at > ?', todos[0][:created_at]).last

      false
    end

    def get_todos(id, page_details)
      return Todo.limit(page_details['size']) unless id

      if page_details.key?('after')
        return Todo.where('created_at < ?',
                          Todo.find(id).created_at).first(page_details['size'].to_i)
      end

      Todo.where('created_at > ?',
                 Todo.find(id).created_at).last(page_details['size'].to_i)
    end
  end
end
