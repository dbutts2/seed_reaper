# frozen_string_literal: true

require 'seed_reaper/seedifier'
require 'seed_reaper/seed_writer'
require 'seed_reaper/railtie' if defined?(Rails)

module SeedReaper
  VERSION = '0.0.1'
end
