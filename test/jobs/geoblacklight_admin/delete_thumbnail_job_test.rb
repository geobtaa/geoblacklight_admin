require "test_helper"

module GeoblacklightAdmin
  class DeleteThumbnailJobTest < ActiveJob::TestCase
    def setup
      @document = documents(:ls)
      @bad_document = bulk_action_documents(:one)
    end

    test "should delete thumbnail if present" do
      perform_enqueued_jobs do
        StoreImageJob.perform_now(@document.friendlier_id)
      end

      perform_enqueued_jobs do
        DeleteThumbnailJob.perform_now(@document.friendlier_id)
      end

      @document.reload
      assert_nil @document.thumbnail
    end

    test "should transition bad document state to success if bad_id is present" do
      perform_enqueued_jobs do
        DeleteThumbnailJob.perform_now(@document.friendlier_id, @bad_document.id)
      end

      @bad_document.reload
      assert_equal "success", @bad_document.state_machine.current_state
    end
  end
end
