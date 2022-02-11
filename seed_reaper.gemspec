# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'seed_reaper'
  s.version = '0.0.1'
  s.summary = 'Subsetter and object to seed serializer.'
  s.description = 'Traverses active record relations given a config and writes seeds to a specified location.'
  s.authors = ['David Butts']
  s.email = 'dbutts2@protonmail.com'
  s.licenses = ['MIT']
  s.files = Dir['lib/**/*']
  s.homepage = 'https://github.com/dbutts2/seed_reaper'
end
