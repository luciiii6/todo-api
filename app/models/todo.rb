# frozen_string_literal: true

class Todo < ApplicationRecord
  scope :sorted_by, ->(attribute, direction = 'DESC') { order("#{attribute} #{direction}") }
end
