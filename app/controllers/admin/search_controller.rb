# frozen_string_literal: true

# Admin::SearchController
module Admin
  class SearchController < ApplicationController
    def index
      @facet_options = BlacklightApiFacets.new.facets
    end
  end
end