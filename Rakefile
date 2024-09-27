# frozen_string_literal: true

require "rubygems"
require "rails"

require "bundler/setup"

# Not using test/dummy app; using engine_cart
# APP_RAKEFILE = File.expand_path(".internal_test_app/Rakefile", __dir__) if
# load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop)

require "engine_cart/rake_task"
require "geoblacklight_admin/version"
require "rake/testtask"
require "geoblacklight_admin/rake_task"
require "simple_form"

# Searches for files ending in _test.rb in the test directory
Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

# Will use test as defaut task if rake is run by itself
task default: :test

desc "Run test suite"
task :ci do

  # Start docker
  Rake::Task["geoblacklight:docker:start"].invoke

  # Create the test rails app
  Rake::Task["geoblacklight:generate"].invoke

  within_test_app do
    require "simple_form"
    system "RAILS_ENV=test bin/rails db:migrate"
    system "RAILS_ENV=test rake db:seed"
    system "RAILS_ENV=test rails webpacker:compile"
  end

  # Run Minitest tests with Coverage
  Rake::Task["geoblacklight:coverage"].invoke

  # Stop docker
  Rake::Task["geoblacklight:docker:stop"].invoke
end

namespace :geoblacklight do
  desc "Run tests with coverage"
  task :coverage do
    ENV["COVERAGE"] = "true"
    # Rake::Task["spec"].invoke
    Rake::Task["test"].invoke
  end

  desc "Create the test rails app"
  task generate: ["engine_cart:generate"] do
    # Intentionally Empty Block
  end

  namespace :internal do
    task seed: ["engine_cart:generate"] do
      within_test_app do
        system "bundle exec rake db:seed"
        system "bundle exec rake geoblacklight:downloads:mkdir"
      end
    end
  end

  desc "Run Solr and seed with sample data"
  task :solr do
    if File.exist? EngineCart.destination
      within_test_app do
        system "bundle update"
      end
    else
      Rake::Task["engine_cart:generate"].invoke
    end
  end

  namespace :docker do
    desc "Start docker and seed with sample data"
    task :start do
      system "docker compose up -d"
      Rake::Task["geoblacklight:internal:seed"].invoke
      puts "\nSolr server running: http://localhost:8983/solr/#/blacklight-core"
      puts "\nPostgreSQL server running: http://localhost:5555"
      puts " "
    end

    desc "Stop docker"
    task :stop do
      system "docker compose down"
    end
  end
end

task default: %i[rubocop ci]
