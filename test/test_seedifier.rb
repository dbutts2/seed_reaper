# frozen_string_literal: true

require 'minitest/autorun'
require 'seedifier'

class FakeModel
end

describe Seedifier do
  describe '#seedify' do
    describe 'when config is just a symbol' do
      it 'returns the serialized seed representation of the collection' do
        config = :fake_model
        Seedifier.new(config).seedify
      end
    end
  end
end
