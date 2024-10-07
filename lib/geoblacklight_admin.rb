# frozen_string_literal: true

require "active_support/dependencies"
require "geoblacklight_admin/engine"
require "zeitwerk"

# Try to avoid autoloading the admin controllers
admin_controllers = "#{__dir__}/app/controllers/admin"

loader = Zeitwerk::Loader.for_gem
loader.do_not_eager_load(admin_controllers)
loader.ignore("#{__dir__}/generators")
loader.setup

module GeoblacklightAdmin
end
