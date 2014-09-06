require "bundler/gem_tasks"
require 'rspec/core'
require 'rspec/core/rake_task'


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end

task :default => :spec
