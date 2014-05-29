# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'cuba-rest'
  s.version = '0.0.1'

  s.summary = 'optimistic find/get on model via updated_at timestamp for datamapper and activerecord'
  s.description = s.summary
  s.homepage = 'http://github.com/mkristian/ixtlan-optimistic'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  # s.files = Dir['MIT-LICENSE']
  # s.licenses << 'MIT'
  # s.files += Dir['README.md']
  # s.files += Dir['lib/**/*']
  # s.files += Dir['spec/**/*']
  # s.test_files += Dir['spec/**/*_spec.rb']

  s.add_runtime_dependency 'cuba', '~>3.1'
  s.add_runtime_dependency 'multi_json', '~>1.10'
  s.add_runtime_dependency 'ixtlan-babel', '~>0.7'
  s.add_runtime_dependency 'ixtlan-datamapper', '~>0.1'
  s.add_runtime_dependency 'safe_yaml', '~>0.9'

  s.add_development_dependency 'awesome_print', '~>1.2'
  s.add_development_dependency 'rack-test', '~>0.6'
  s.add_development_dependency 'cutest-cj', '~>1.2'
  s.add_development_dependency 'minitest', '~>5.0'
  s.add_development_dependency 'dm-timestamps', '1.2.0'
  s.add_development_dependency 'dm-migrations', '1.2.0'
  s.add_development_dependency 'dm-validations', '1.2.0'
  s.add_development_dependency 'dm-sqlite-adapter', '1.2.0'
  s.add_development_dependency 'rake', '~>10.0.2'
end

# vim: syntax=Ruby
