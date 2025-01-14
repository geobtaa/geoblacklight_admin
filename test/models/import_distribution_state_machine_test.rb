# frozen_string_literal: true

require "test_helper"

class ImportDistributionStateMachineTest < ActiveSupport::TestCase
  test "states" do
    assert_equal(ImportDistributionStateMachine.states, %w[created mapped imported success failed])
  end
end
