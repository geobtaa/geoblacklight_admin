# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# SimpleCov
require "simplecov"
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start "rails" do
  add_filter "lib/generators/geoblacklight_admin/install_generator.rb"
  add_filter "lib/geoblacklight_admin/version.rb"
  add_filter "lib/generators"
  add_filter "lib/geoblacklight_admin/tasks/*.rake"
  add_filter "/spec"
  add_filter ".internal_test_app/"
  minimum_coverage 100
end

require_relative "../.internal_test_app/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../.internal_test_app/db/migrate", __dir__)]
# ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require "database_cleaner/active_record"
DatabaseCleaner.strategy = :truncation

require "minitest/rails"
require "minitest/reporters"

require "webmock/minitest"
WebMock.enable!
WebMock.allow_net_connect!

# DB needs to be clean and seeded
DatabaseCleaner.clean
Rails.application.load_seed

ActiveJob::Base.queue_adapter = :test

module ActiveSupport
  class TestCase
    # extend ActiveStorageValidations::Matchers
    fixtures :all

    include Devise::Test::IntegrationHelpers
    include Warden::Test::Helpers

    def sign_in_as(user_or_key)
      u = user_or_key
      u = users(user_or_key) if u.is_a? Symbol
      sign_in(u)
    end

    def sign_out_as(user_or_key)
      u = user_or_key
      u = users(user_or_key) if u.is_a? Symbol
      sign_out u
    end

    def setup
      # DatabaseCleaner.start
    end

    def teardown
      # DatabaseCleaner.clean
    end
  end
end
