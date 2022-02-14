# frozen_string_literal: true

require 'spec_helper'
require 'active_record'
require 'seedifier'

describe Seedifier do
  before(:all) do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :things, force: true do |t|
        t.string :some_attribute
      end
    end

    class Thing < ActiveRecord::Base
    end
  end

  describe '#seedify' do
    context 'with a symbol' do
      subject { described_class.new(:thing) }

      context 'with no records' do
        it 'is a blank string' do
          expect(subject.seedify).to eq ''
        end
      end

      context 'with a record' do
        let!(:thing) { Thing.create!(some_attribute: 'some value') }

        it 'is the seedified record' do
          expect(subject.seedify).to eq <<~SEED
            Thing.new(
              id: #{thing.id},
              some_attribute: "#{thing.some_attribute}"
            ).save!(validate: false)

          SEED
        end
      end
    end
  end
end
