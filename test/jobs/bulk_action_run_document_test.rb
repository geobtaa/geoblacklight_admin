require "test_helper"

class BulkActionRunDocumentJobTest < ActiveJob::TestCase
  def setup
    @document = documents(:ag)
    @job = BulkActionRunDocumentJob.new
  end

  test "should update publication status" do
    assert_changes -> { @document.reload.publication_state }, from: "published", to: "draft" do
      @job.perform(:update_publication_status, @document, nil, "draft")
    end
    assert_equal "draft", @document.state_machine.current_state
  end

  test "should update delete" do
    assert_difference "Document.count", -1 do
      @job.perform(:update_delete, @document, nil, nil)
    end
  end

  test "should enqueue harvest thumbnails job" do
    assert_enqueued_with(job: GeoblacklightAdmin::StoreImageJob) do
      @job.perform(:harvest_thumbnails, @document, nil, nil)
    end
  end

  test "should enqueue delete thumbnails job" do
    assert_enqueued_with(job: GeoblacklightAdmin::DeleteThumbnailJob) do
      @job.perform(:delete_thumbnails, @document, nil, nil)
    end
  end
end
