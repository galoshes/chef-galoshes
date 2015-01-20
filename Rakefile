require 'rubocop/rake_task'
require 'foodcritic'
require 'foodcritic/rake_task'
require 'rspec/core/rake_task'
require 'codeclimate-test-reporter'

desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = false
end

desc 'Run Foodcritic lint checks'
FoodCritic::Rake::LintTask.new(:lint) do |t|
  t.options = {
    :fail_tags => ['any'],
  }
end

desc 'Run all tests'
task :test => [:rubocop, :lint, :spec]
task :default => :test
