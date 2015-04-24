require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'maven/ruby/maven'

RSpec::Core::RakeTask.new :spec do |spec|
  spec.rspec_opts = '--format documentation --color'
end

RuboCop::RakeTask.new

task :download_jars do
  mvn = Maven::Ruby::Maven.new
  mvn.exec 'generate-sources', '-f', 'pom.xml'
end

#Do not run the task, since custom jars were already added to the project jars folder.
#task build: :download_jars
