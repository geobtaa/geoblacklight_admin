# frozen_string_literal: true

require "rubygems"
require "rails"

require "bundler/setup"

# Not using test/dummy app; using engine_cart
# APP_RAKEFILE = File.expand_path(".internal_test_app/Rakefile", __dir__) if
# load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

require "solr_wrapper"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop)

require "solr_wrapper/rake_task"
require "engine_cart/rake_task"
require "geoblacklight_admin/version"
require "rake/testtask"

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
task ci: ["geoblacklight:generate"] do
  within_test_app do
    system "RAILS_ENV=test rake db:seed"
    system "RAILS_ENV=test rake geoblacklight:index:seed"
  end

  # Run RSpec tests with Coverage
  Rake::Task["geoblacklight:coverage"].invoke
end

namespace :geoblacklight do
  desc "Run tests with coverage"
  task :coverage do
    ENV["COVERAGE"] = "true"
    # Rake::Task["spec"].invoke
    system("RAILS_ENV=test bundle exec rails test") || false
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

    SolrWrapper.wrap(port: "8983") do |solr|
      solr.with_collection(name: "blacklight-core",
        dir: File.join(File.expand_path(".", File.dirname(__FILE__)),
          "solr", "conf")) do
        Rake::Task["geoblacklight:internal:seed"].invoke

        within_test_app do
          puts "\nSolr server running: http://localhost:#{solr.port}/solr/#/blacklight-core"
          puts "\n^C to stop"
          puts " "
          begin
            sleep
          rescue Interrupt
            puts "Shutting down..."
          end
        end
      end
    end
  end
end

task default: %i[rubocop ci]
