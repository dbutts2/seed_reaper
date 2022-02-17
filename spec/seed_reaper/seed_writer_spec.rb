# frozen_string_literal: true

require 'spec_helper'
require 'seed_reaper/seed_writer'

describe SeedReaper::SeedWriter do
  let!(:config) { [:something, something_else: :some_associations] }

  describe '#write!' do
    it 'writes to db/seeds/0_something.seeds.rb and 1_something_else.seeds.rb' do
      expect(File).to receive(:open).with('db/seeds/0_something.seeds.rb', 'w')
      expect(File).to receive(:open).with('db/seeds/1_something_else.seeds.rb', 'w')
      described_class.new(config).write!
    end
  end
end
