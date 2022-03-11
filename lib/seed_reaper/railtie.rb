# frozen_string_literal: true

require 'seed_reaper'

module SeedReaper
  class Railtie < Rails::Railtie
    railtie_name :seed_reaper

    rake_tasks do
      spec = Gem::Specification.find_by_name 'seed_reaper'
      load "#{spec.gem_dir}/lib/tasks/seed_reaper.rake"
    end
  end
end
