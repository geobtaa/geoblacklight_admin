# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies Kithe initializer file to host config
       2. Copies statesman initializer file to host config
       3. Copies PG database.yml connection to host config
    DESCRIPTION

    def create_kithe_initializer
      copy_file "config/initializers/kithe.rb", "config/initializers/kithe.rb"
    end

    def create_statesman_initializer
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end

    def create_database_yml
      copy_file "config/database.yml", "config/database.yml"
    end

    def set_gems
      append_to_file "Gemfile" do
        "
          gem 'kithe'
          gem 'paper_trail'
        "
      end
    end
  end
end
