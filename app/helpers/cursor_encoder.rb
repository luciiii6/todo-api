# frozen_string_literal: true

class CursorEncoder
  class << self
    def encode(created_at)
      Base64.strict_encode64(created_at)
    end

    def decode(created_at)
      Base64.strict_decode64(created_at)
    end
  end
end
