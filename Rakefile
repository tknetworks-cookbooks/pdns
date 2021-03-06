#!/usr/bin/env rake
#
# See http://technology.customink.com/blog/2012/06/04/mvt-foodcritic-and-travis-ci/
#
require 'rspec/core/rake_task'

desc 'Runs foodcritic linter'
task :foodcritic do
  paths = %w{tmp foodcritic cookbook}
  sandbox = File.join(File.dirname(__FILE__), paths)
  prepare_foodcritic_sandbox(sandbox)

  excluded_rules = %w{FC003 FC015 FC009}

  begin
    tags = excluded_rules.map { |r| "--tags ~#{r}" }
    sh "foodcritic -C #{tags.join(" ")} --epic-fail any #{File.dirname(sandbox)}"
  ensure
    teardown_foodcritic_sandbox(File.join(File.dirname(__FILE__), paths.first))
  end
end

desc 'Runs berkshelf'
task :berkshelf do
  teardown_berkshelf
  berkshelf
end

task :default => %w{foodcritic berkshelf test}
task :spec => :test

RSpec::Core::RakeTask.new(:test)

private

def prepare_foodcritic_sandbox(sandbox)
  files = %w{
    *.md *.rb attributes definitions files libraries providers recipes resources templates
  }

  rm_rf sandbox
  mkdir_p sandbox
  cp_r Dir.glob("{#{files.join(',')}}"), sandbox
  puts "\n\n"
end

def teardown_foodcritic_sandbox(sandbox_root)
  rm_rf sandbox_root
end

def berkshelf
  sh "berks install --path vendor/cookbooks"
end

def teardown_berkshelf
  rm_rf 'vendor'
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end
