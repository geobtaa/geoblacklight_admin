# frozen_string_literal: true

# GeoblacklightAdmin::SearchController
module GeoblacklightAdmin
  class SearchController < GeoblacklightAdmin::AdminController
    def index
      @facet_options = BlacklightApiFacets.new.facets
    end
  end
end
