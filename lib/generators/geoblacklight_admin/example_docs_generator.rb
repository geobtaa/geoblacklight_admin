# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ExampleDocsGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../spec/fixtures", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies the dir of example solr doc files to host app/solr/geoblacklight/example_docs
    DESCRIPTION

    def create_services
      directory "files", "solr/geoblacklight/example_docs"
    end
  end
end
