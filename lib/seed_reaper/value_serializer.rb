# frozen_string_literal: true

module SeedReaper
  class ValueSerializer
    def initialize(value)
      @value = value
    end

    def serialized(nullify: false)
      @serialized ||=
        if nullify || @value.nil?
          "nil"
        elsif @value.is_a?(Integer)
          @value
        else
          "%q{#{@value}}"
        end
    end
  end
end
