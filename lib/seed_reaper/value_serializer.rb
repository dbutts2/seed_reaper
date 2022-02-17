# frozen_string_literal: true

module SeedReaper
  class ValueSerializer
    def initialize(value)
      @value = value
    end

    def serialized
      @serialized ||=
        if @value.nil?
          "nil"
        elsif @value.is_a?(Integer)
          @value
        else
          "%q{#{@value}}"
        end
    end
  end
end
