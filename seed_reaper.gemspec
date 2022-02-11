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

  s.add_runtime_dependency 'activesupport', '>= 2.3.5'
  s.add_development_dependency 'shoulda', '>= 4'
  s.add_development_dependency 'rdoc', '~> 6.4'
  s.add_development_dependency 'bundler', '~> 2.3'
  s.add_development_dependency 'juwelier', '~> 2.1.0'
  s.add_development_dependency 'simplecov', '>= 0'
end
