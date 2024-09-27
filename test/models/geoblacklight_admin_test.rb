# frozen_string_literal: true

require "test_helper"

class GeoblacklightAdminTest < ActiveSupport::TestCase
  test "should respond to language_name method from IsoLanguageCodes" do
    assert_equal "English", GeoblacklightAdmin::IsoLanguageCodes.call["eng"]
    assert_equal "French", GeoblacklightAdmin::IsoLanguageCodes.call["fra"]
    assert_nil GeoblacklightAdmin::IsoLanguageCodes.call["de"]
  end
end
