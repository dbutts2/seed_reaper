# frozen_string_literal: true

require 'minitest/autorun'
require 'config_evaluator'

describe ConfigEvaluator do
  describe '#schema' do
    describe 'when config is nil' do
      it 'is nill' do
        assert_nil ConfigEvaluator.new(nil).schema
      end
    end

    describe 'with no meta' do
      it 'is just the config itself' do
        config = [:assoc, assoc2: :nested_assoc2]

        assert_equal(ConfigEvaluator.new(config).schema, config)
      end
    end

    describe 'with meta' do
      describe 'in a hash' do
        it 'is does not include meta' do
          schema = { association: :nested_association }

          assert_equal(
            ConfigEvaluator.new(
              { **schema, meta: { count: 10 } }
            ).schema, schema
          )
        end
      end

      describe 'in an array' do
        it 'is does not include meta' do
          schema = :association

          assert_equal(
            ConfigEvaluator.new(
              [ schema, { meta: { count: 10 } } ]
            ).schema, [schema]
          )
        end
      end
    end
  end

  %i[count joins].each do |field|
    describe "##{field}" do
      it "returns the value of the #{field} meta field" do
        expectation = 'test val'
        config = { assoc: :nested_assoc, meta: { field => expectation } }

        assert_equal(ConfigEvaluator.new(config).send(field), expectation)
      end
    end
  end
end
