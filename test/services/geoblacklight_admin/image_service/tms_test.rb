require "test_helper"

module GeoblacklightAdmin
  class ImageService::TmsTest < ActiveSupport::TestCase
    def setup
      @base_url = "https://cugir.library.cornell.edu/geoserver"
      @layer_id = "cugir007957"
      @document = create_mock_document(@base_url, @layer_id)
    end

    test "generates correct TMS image URL" do
      [800, 1000, 1500].each do |size|
        expected_url = "#{@base_url}/wms/reflect?FORMAT=image%2Fpng&TRANSPARENT=TRUE&LAYERS=#{@layer_id}&WIDTH=#{size}&HEIGHT=#{size}"
        assert_equal expected_url, GeoblacklightAdmin::ImageService::Tms.image_url(@document, size)
      end
    end

    test "handles different viewer endpoints" do
      different_document = create_mock_document("https://example.com/geoserver", "example123")
      size = 800
      expected_url = "https://example.com/geoserver/wms/reflect?FORMAT=image%2Fpng&TRANSPARENT=TRUE&LAYERS=example123&WIDTH=800&HEIGHT=800"
      assert_equal expected_url, GeoblacklightAdmin::ImageService::Tms.image_url(different_document, size)
    end

    test "raises error for invalid document" do
      invalid_document = Minitest::Mock.new
      invalid_document.expect(:viewer_endpoint, nil)
      assert_raises(RuntimeError) { GeoblacklightAdmin::ImageService::Tms.image_url(invalid_document, 1000) }
    end

    private

    def create_mock_document(base_url, layer_id)
      document = Minitest::Mock.new
      document.expect(:viewer_endpoint, "#{base_url}/gwc/service/tms/1.0.0/cugir%3A#{layer_id}@EPSG%3A3857@png/{z}/{x}/{y}.png")
      document.expect(:viewer_endpoint, "#{base_url}/gwc/service/tms/1.0.0/cugir%3A#{layer_id}@EPSG%3A3857@png/{z}/{x}/{y}.png")
      document.expect(:viewer_endpoint, "#{base_url}/gwc/service/tms/1.0.0/cugir%3A#{layer_id}@EPSG%3A3857@png/{z}/{x}/{y}.png")
      document.expect(:[], layer_id, ["gbl_wxsIdentifier_s"])
      document.expect(:[], layer_id, ["gbl_wxsIdentifier_s"])
      document.expect(:[], layer_id, ["gbl_wxsIdentifier_s"])
      document
    end
  end
end
