require "test_helper"

module BulkActions
  class ChangePublicationStateTest < ActiveSupport::TestCase
    test "should be a subclass of BulkAction" do
      assert ChangePublicationState < BulkAction
    end
  end
end
