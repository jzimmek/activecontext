Gem::Specification.new do |s|
  s.name = 'activecontext'
  s.version = '0.2.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['jan zimmek']
  s.email = ['jan.zimmek@web.de']
  s.homepage = 'http://www.github.com/jzimmek/activecontext'
  s.summary = ''
  s.description = s.summary

  s.required_ruby_version = '>=1.9.2'
  # s.add_dependency 'active_support'

  s.add_development_dependency 'rspec'

  s.files = Dir['lib/**/**','spec/**/**']
  s.require_paths = ['lib']
end