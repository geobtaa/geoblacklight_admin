# frozen_string_literal: true

# Admin::SearchController
module Admin
  class SearchController < Admin::AdminController
    def index
      @facet_options = BlacklightApiFacets.new.facets
    end
  end
end