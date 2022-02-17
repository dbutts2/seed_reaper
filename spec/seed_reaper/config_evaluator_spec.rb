# frozen_string_literal: true

require 'spec_helper'
require 'seed_reaper/config_evaluator'

describe SeedReaper::ConfigEvaluator do
  describe '#schema' do
    describe 'when config is nil' do
      it 'is nill' do
        expect(described_class.new(nil).schema).to eq(nil)
      end
    end

    describe 'with no meta' do
      it 'is just the config itself' do
        config = [:assoc, assoc2: :nested_assoc2]

        expect(described_class.new(config).schema).to eq(config)
      end
    end

    describe 'with meta' do
      describe 'in a hash' do
        it 'is does not include meta' do
          schema = { association: :nested_association }

          expect(
            described_class.new(
              { **schema, meta: { count: 10 } }
            ).schema
          ).to eq(schema)
        end
      end

      describe 'in an array' do
        it 'is does not include meta' do
          schema = :association

          expect(
            described_class.new(
              [ schema, { meta: { count: 10 } } ]
            ).schema
          ).to eq([schema])
        end
      end
    end
  end

  %i[count joins].each do |field|
    describe "##{field}" do
      it "returns the value of the #{field} meta field" do
        expectation = 'test val'
        config = { assoc: :nested_assoc, meta: { field => expectation } }

        expect(described_class.new(config).send(field)).to eq(expectation)
      end
    end
  end
end
