# frozen_string_literal: true

require "rails"

module GeoblacklightAdmin
  class Engine < ::Rails::Engine
    isolate_namespace GeoblacklightAdmin

    # GeoblacklightAdminHelper is needed by all helpers, so we inject it
    # into action view base here.
    initializer "geoblacklight_admin.helpers" do
      config.after_initialize do
        ActionView::Base.include GeoblacklightAdminHelper
        ActionView::Base.include BulkActionsHelper
        ActionView::Base.include DocumentHelper
        ActionView::Base.include FormInputHelper
        ActionView::Base.include MappingsHelper
      end
    end
  end
end
