# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start "rails" do
  add_filter "lib/generators/geoblacklight_admin/install_generator.rb"
  add_filter "lib/geoblacklight_admin/version.rb"
  add_filter "lib/generators"
  add_filter "lib/tasks/geoblacklight_admin.rake"
  add_filter "/test"
  add_filter ".internal_test_app/"
  minimum_coverage 100
end

require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "geoblacklight_admin"

require "database_cleaner/active_record"
DatabaseCleaner.strategy = :truncation

require "engine_cart"
EngineCart.load_application!

Minitest::Reporters.use!

# DB needs to be clean and seeded
DatabaseCleaner.clean
Rails.application.load_seed

module ActiveSupport
  class TestCase

    ## @TODO
    ## extend ActiveStorageValidations::Matchers
    ## fixtures :all

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
      DatabaseCleaner.start
    end

    def teardown
      DatabaseCleaner.clean
    end
  end
end