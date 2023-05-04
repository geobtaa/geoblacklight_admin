# frozen_string_literal: true

module GeoblacklightAdmin
  class Engine < ::Rails::Engine
    isolate_namespace GeoblacklightAdmin

    # GeoblacklightAdminHelper is needed by all helpers, so we inject it
    # into action view base here.
    initializer "geoblacklight_admin.helpers" do
      config.after_initialize do
        ActionView::Base.send :include, GeoblacklightAdminHelper
      end
    end
  end
end
