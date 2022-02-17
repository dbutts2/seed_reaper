# frozen_string_literal: true

require 'seed_reaper'

module SeedReaper
  class Railtie < Rails::Railtie
    railtie_name :seed_reaper

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
