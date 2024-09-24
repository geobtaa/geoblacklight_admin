# frozen_string_literal: true

require "test_helper"
require "addressable/uri"

module GeoblacklightAdmin
  class ImageService::TmsTest < ActiveSupport::TestCase
    setup do
      # Create a mock SolrDocument with necessary fields
      @document = Minitest::Mock.new
      @document.expect(:viewer_endpoint, "https://cugir.library.cornell.edu/geoserver/gwc/service/tms/1.0.0/cugir%3Acugir007957@EPSG%3A3857@png/{z}/{x}/{y}.png")
      @document.expect(:[], "cugir007957", ["gbl_wxsIdentifier_s"])
    end

    test "should generate correct TMS image URL with specified size" do
      size = 1500
      expected_url = "https://cugir.library.cornell.edu/geoserver/wms/reflect?" \
                     "&FORMAT=image%2Fpng" \
                     "&TRANSPARENT=TRUE" \
                     "&LAYERS=cugir007957" \
                     "&WIDTH=1500" \
                     "&HEIGHT=1500"

      actual_url = GeoblacklightAdmin::ImageService::Tms.image_url(@document, size)
      assert_equal expected_url, actual_url
    end

    test "should generate correct TMS image URL with different size" do
      size = 1000
      expected_url = "https://cugir.library.cornell.edu/geoserver/wms/reflect?" \
                     "&FORMAT=image%2Fpng" \
                     "&TRANSPARENT=TRUE" \
                     "&LAYERS=cugir007957" \
                     "&WIDTH=1000" \
                     "&HEIGHT=1000"

      actual_url = GeoblacklightAdmin::ImageService::Tms.image_url(@document, size)
      assert_equal expected_url, actual_url
    end

    teardown do
      # Verify that the expectations on the mock were met
      @document.verify
    end
  end
end
