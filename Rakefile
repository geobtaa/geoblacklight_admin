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

desc "Run test suite"
task "ci" do
  ENV["RAILS_ENV"] = "test"
  system("RAILS_ENV=test bundle exec rake test") || false
  system("RAILS_ENV=test bundle exec rake geomg:solr:reindex") || false
end

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

namespace :geoblacklight do
  namespace :internal do
    task seed: ["engine_cart:generate"] do
      within_test_app do
        # @TODO - Seed Elements / FormElements
        # system "bundle exec rake gbl_admin:seed"
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
