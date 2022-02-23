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
    end

    class Thing < ActiveRecord::Base
      has_many :associated_things, dependent: :destroy
    end

    class AssociatedThing < ActiveRecord::Base
      belongs_to :thing
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
    end
  end
end
