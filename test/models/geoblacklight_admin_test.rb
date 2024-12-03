# frozen_string_literal: true

require "test_helper"

class GeoblacklightAdminTest < ActiveSupport::TestCase
  setup do
    @dummy_class = Class.new do
      include GeoblacklightAdmin
    end
  end

  def test_module_defined
    assert defined?(GeoblacklightAdmin), "GeoblacklightAdmin module should be defined"
  end

  def test_module_inclusion
    assert_includes @dummy_class.included_modules, GeoblacklightAdmin, "GeoblacklightAdmin should be included in DummyClass"
  end
end