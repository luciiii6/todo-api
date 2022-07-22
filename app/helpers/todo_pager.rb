# frozen_string_literal: true

class TodoPager
  DEFAULT_SIZE = 20

  class << self
    def get_page(page_details)
      return { todos: Todo.all.collect { |todo| TodoPresenter.new(todo).to_h }, metadata: {} } unless page_details

      default_page_settings(page_details)

      if PageParametersValidator.valid?(page_details)
        id = id(page_details)
        sorter = TodoSorter.create(id, page_details)
        data = get_data(sorter)
        metadata = get_metadata(sorter)
      end

      {
        todos: data.collect { |todo| TodoPresenter.new(todo).to_h },
        metadata: metadata
      }
    end

    private

    def get_data(sorter)
      data = sorter.todos

      raise PageParametersValidator::PageError, 'Non existent items this way' if data.empty?

      data
    end

    def get_metadata(sorter)
      {
        firstCursor: sorter.first_cursor,
        lastCursor: sorter.last_cursor,
        hasNextPage: sorter.next_page?,
        hasPreviousPage: sorter.previous_page?
      }
    end

    def id(page_details)
      return CursorEncoder.decode(page_details['after']) if page_details.key?('after')
      return CursorEncoder.decode(page_details['before']) if page_details.key?('before')
    end

    def default_page_settings(page_details)
      page_details['size'] = DEFAULT_SIZE unless page_details.key?('size')
      page_details['direction'] = 'DESC' unless page_details.key?('direction')
      page_details['sort_by'] = 'created_at' unless page_details.key?('sort_by')
    end
  end
end
