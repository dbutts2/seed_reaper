# frozen_string_literal: true

require 'yaml'
require 'seed_reaper'

namespace :seed_reaper do
  desc 'Write seeds to db/seeds/ based on config/seed_reaper.yml.'
  task :write do
    SeedReaper::SeedWriter.new(
      YAML.load(
        File.read('config/seed_reaper.yml')
      )
    ).write!
  end
end
