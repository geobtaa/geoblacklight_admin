# frozen_string_literal: true

# Admin::SearchController
module Admin
  class SearchController < Admin::AdminController
    def index
      @request = "#{request.protocol}#{request.host}:#{request.port}"
      @facet_options = BlacklightApiFacets.new(@request).facets
    end
  end
end
