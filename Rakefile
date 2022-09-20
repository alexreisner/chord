require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
desc "Run unit tests"
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/unit/**/*_test.rb'
end

task :default => [:test]
