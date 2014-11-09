require 'rubocop/rake_task'
require 'foodcritic'
require 'foodcritic/rake_task'

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
task :test => [:lint, :rubocop]
task :default => :test
