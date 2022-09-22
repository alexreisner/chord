# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'date'
require 'chord/version'

Gem::Specification.new do |s|
  s.name        = "chord"
  s.required_ruby_version = '>= 2.0.0'
  s.version     = Chord::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Reisner"]
  s.email       = ["alex@alexreisner.com"]
  s.homepage    = "https://www.github.com/alexreisner/chord"
  s.date        = Date.today.to_s
  s.summary     = "Easy access to Chord Commerce API."
  s.description = "ActiveRecord-like syntax. Still in alpha-stage early development. Many endpoints and features not yet supported. Some bugs."
  s.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*', 'bin/*']
  s.require_paths = ["lib"]
  s.license     = 'MIT'
  s.add_runtime_dependency 'httparty', '~> 0.20.0'
  s.metadata = {
    'source_code_uri' => 'https://github.com/alexreisner/chord',
    'changelog_uri'   => 'https://github.com/alexreisner/chord/blob/master/CHANGELOG.md'
  }
end
