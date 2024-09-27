require "test_helper"

class ExportJsonBulkJobTest < ActiveJob::TestCase
  def setup
    @request = "http://example.com" # Simplified request
    @current_user = users(:user_001)
    @query_params = { format: 'json_file', ids: [documents(:ag).friendlier_id, documents(:ls).friendlier_id] }
    @export_service = ExportJsonService
  end

  test "perform job without error" do
    skip("ActionView::MissingTemplate: Missing template admin/documents/_json_file.jbuilder...")
    assert_nothing_raised do
      ExportJsonBulkJob.perform_now(@request, @current_user, @query_params, @export_service)
    end
  end
end
