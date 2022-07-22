# frozen_string_literal: true

class TodoSorter
  class << self
    def create(id, page_details)
      TodoSorter.new(id, page_details['sort_by'],
                     page_details['size'], page_details['direction'],
                     comparator(page_details))
    end

    private

    def comparator(page_details)
      return page_details['direction'] == 'DESC' ? '>' : '<' if page_details.key?('before')

      page_details['direction'] == 'DESC' ? '<' : '>'
    end
  end

  def todos
    return @data = Todo.sorted_by(@attribute, @direction).limit(@size) unless @id

    @data = Todo.sorted_by(@attribute, @direction)
                .where(" \"#{@attribute}\" #{@comparator} ?",
                       Todo.find(@id).attributes[@attribute])
                .first(@size)
  end

  def next_page?
    return true if Todo.sorted_by(@attribute, @direction)
                       .where("\"#{@attribute}\" #{@comparator} ?", @data[-1].attributes[@attribute])
                       .first

    false
  end

  def previous_page?
    return true if Todo.sorted_by(@attribute, @direction)
                       .where("\"#{@attribute}\" #{@comparator} ?", @data[0].attributes[@attribute])
                       .first

    false
  end

  def first_cursor
    CursorEncoder.encode(@data[0].id.to_s)
  end

  def last_cursor
    CursorEncoder.encode(@data[-1].id.to_s)
  end

  private

  def initialize(id, attribute, size, direction, comparator)
    @id = id
    @attribute = attribute
    @size = size.to_i
    @direction = direction
    @comparator = comparator
  end
end
