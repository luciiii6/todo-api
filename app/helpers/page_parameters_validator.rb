# frozen_string_literal: true

class PageParametersValidator
  class PageError < StandardError
  end

  class << self
    def valid?(parameters)
      if (parameters.key?('before') && parameters.key?('after')) || !Todo.has_attribute?(parameters['sort_by'])
        raise PageError, "Can't have before and after in the same request"
      end

      true
    end
  end
end
