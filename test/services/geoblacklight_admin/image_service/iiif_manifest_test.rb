# frozen_string_literal: true

require "test_helper"
require "down"
require "json"

module GeoblacklightAdmin
  class ImageService::IiifManifestTest < ActiveSupport::TestCase
    setup do
      @document = Minitest::Mock.new
      @document.expect(:viewer_endpoint, "https://example.com/manifest.json")

      @manifest_content = {
        "sequences" => [
          {
            "canvases" => [
              {
                "images" => [
                  {
                    "resource" => {
                      "service" => {
                        "@id" => "https://example.com/image"
                      }
                    }
                  }
                ]
              }
            ]
          }
        ]
      }.to_json
    end

    test "should download manifest" do
      Down.stub :download, StringIO.new(@manifest_content) do
        size = 1500
        manifest = GeoblacklightAdmin::ImageService::IiifManifest.image_url(@document, size)
        assert_equal JSON.parse(@manifest_content), manifest
      end
    end

    test "should have manifest structure" do
      manifest = JSON.parse(@manifest_content)
      assert_includes manifest, "sequences"
      assert_includes manifest["sequences"].first, "canvases"
      assert_includes manifest["sequences"].first["canvases"].first, "images"
      assert_includes manifest["sequences"].first["canvases"].first["images"].first, "resource"
      assert_includes manifest["sequences"].first["canvases"].first["images"].first["resource"], "service"
      assert_equal "https://example.com/image", manifest["sequences"].first["canvases"].first["images"].first["resource"]["service"]["@id"]
    end

    teardown do
      # Verify that the expectations on the mock were met
      @document.verify
    end
  end
end
