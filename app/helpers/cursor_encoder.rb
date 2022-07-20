# frozen_string_literal: true

class CursorEncoder
  class << self
    def encode(id)
      Base64.strict_encode64(id)
    end

    def decode(id)
      Base64.strict_decode64(id)
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
  end
end
