# frozen_string_literal: true

require 'spec_helper'
require 'active_record'
require 'seed_reaper/seedifier'

describe SeedReaper::Seedifier do
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

      create_table :associated_things, force: true do |t|
        t.references :thing
        t.string :another_attribute
      end

      create_table :scoped_things, force: true do |t|
        t.string :some_attribute
      end

      create_table :has_no_models, force: true do |t|
        t.string :some_attribute
      end
    end

    class Thing < ActiveRecord::Base
      has_many :associated_things, dependent: :destroy
    end

    class AssociatedThing < ActiveRecord::Base
      belongs_to :thing
    end

    module Scoped
      class Thing < ActiveRecord::Base
        self.table_name = :scoped_things
      end
    end
  end

  let(:thing) do
    Thing.create!(
      some_attribute: 'some value',
      associated_things: [
        AssociatedThing.new(another_attribute: 'some other value'),
        AssociatedThing.new(another_attribute: 'some other value again')
      ]
    )
  end

  # rollback
  after(:each) { Thing.destroy_all }

  describe '#seedify' do
    context 'with a symbol' do
      subject { described_class.new(:thing) }

      context 'with no things' do
        it 'is a blank string' do
          expect(subject.seedify).to eq ''
        end
      end

      context 'with a thing' do
        before { thing }

        it 'is the seedified thing' do
          expect(subject.seedify).to eq <<~SEED
            Thing.new(
              id: #{thing.id},
              some_attribute: %q{#{thing.some_attribute}}
            ).save!(validate: false)

          SEED
        end
      end
    end

    context 'with a hash' do
      before { thing }
      subject { described_class.new(config) }

      context 'with a thing and assoicated things' do
        let(:config) { { thing: :associated_things } }

        it 'is the seedified thing and associated things' do
          expect(subject.seedify).to eq <<~SEED
            Thing.new(
              id: #{thing.id},
              some_attribute: %q{#{thing.some_attribute}}
            ).save!(validate: false)

            #{
              thing.associated_things.map do |at|
                <<~ASSOC_SEED
                  AssociatedThing.new(
                    id: #{at.id},
                    thing_id: #{thing.id},
                    another_attribute: %q{#{at.another_attribute}}
                  ).save!(validate: false)
                ASSOC_SEED
              end.join("\n")
            }
          SEED
        end
      end

      context 'when the relationship config is reversed' do
        let(:config) { { associated_thing: :thing } }

        it 'serializes the belongs_to dependency before the dependent' do
          expect(subject.seedify).to eq <<~SEED
            Thing.new(
              id: #{thing.id},
              some_attribute: %q{#{thing.some_attribute}}
            ).save!(validate: false)

            #{
              thing.associated_things.map do |at|
                <<~ASSOC_SEED
                  AssociatedThing.new(
                    id: #{at.id},
                    thing_id: #{thing.id},
                    another_attribute: %q{#{at.another_attribute}}
                  ).save!(validate: false)
                ASSOC_SEED
              end.join("\n")
            }
          SEED
        end
      end

      context 'when nullifying thing_id' do
        let(:config) { { associated_thing: { meta: { nullify: :thing_id } } } }

        it 'serializes the associated things without thing_id' do
          expect(subject.seedify).to eq <<~SEED
            #{
              AssociatedThing.all.map do |at|
                <<~ASSOC_SEED
                  AssociatedThing.new(
                    id: #{at.id},
                    thing_id: nil,
                    another_attribute: %q{#{at.another_attribute}}
                  ).save!(validate: false)
                ASSOC_SEED
              end.join("\n")
            }
          SEED
        end
      end

      context 'with a special model name' do
        let!(:scoped_thing) do
          Scoped::Thing.create!(
            some_attribute: 'some value'
          )
        end

        let(:config) { { scoped_thing: { meta: { class_name: 'Scoped::Thing' } } } }

        it 'is the seedified scoped thing' do
          expect(subject.seedify).to eq <<~SEED
            Scoped::Thing.new(
              id: #{scoped_thing.id},
              some_attribute: %q{#{scoped_thing.some_attribute}}
            ).save!(validate: false)

          SEED
        end
      end

      context 'with has_no_models' do
        before do
          (
            Class.new(ActiveRecord::Base) do
              self.table_name = :has_no_models
            end
          ).upsert_all([
            { some_attribute: 'val 1' },
            { some_attribute: 'val 2' }
          ])
        end

        let(:config) { { has_no_models: { meta: { table_only: true } } } }

        it 'is an anonymous upsert' do
          expect(subject.seedify).to eq <<~SEED
            (
              Class.new(ActiveRecord::Base) do
                self.table_name = :has_no_models
              end
            ).upsert_all([
              { id: 1, some_attribute: %q{val 1} },
              { id: 2, some_attribute: %q{val 2} }
            ])
          SEED
        end
      end
    end
  end
end
