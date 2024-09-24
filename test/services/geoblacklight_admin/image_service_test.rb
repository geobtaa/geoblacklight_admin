require "test_helper"
require "tempfile"
require "faraday"

module GeoblacklightAdmin
  class ImageServiceTest < ActiveSupport::TestCase
    def setup
      @document = Minitest::Mock.new
      @document.expect :id, "1234"
      @document.expect :thumbnail_state_machine, Minitest::Mock.new
      @document.thumbnail_state_machine.expect :transition_to!, nil, [:processing, Hash]
      @document.expect :viewer_protocol, "http"
      @document.expect :references, {"http://schema.org/thumbnailUrl" => "http://example.com/thumbnail.jpg"}
      @document.expect :local_restricted?, false
      @document.expect :available?, true

      @service = GeoblacklightAdmin::ImageService.new(@document)
    end

    def test_initialize
      assert_equal @document, @service.document
      assert_equal "1234", @service.instance_variable_get(:@metadata)["solr_doc_id"]
      assert_equal false, @service.instance_variable_get(:@metadata)["placeheld"]
    end

    def test_store_with_nil_io_file
      @service.stub :image_tempfile, nil do
        @document.thumbnail_state_machine.expect :transition_to!, nil, [:placeheld, Hash]
        @service.store
        assert_equal "NIL", @service.instance_variable_get(:@metadata)["IO"]
      end
    end

    def test_store_with_valid_io_file
      tempfile = Tempfile.new("test")
      @service.stub :image_tempfile, tempfile do
        @service.stub :attach_io, nil do
          @service.store
          assert_nil @service.instance_variable_get(:@metadata)["IO"]
        end
      end
    end

    def test_image_tempfile_with_valid_image_data
      @service.stub :image_data, "image data" do
        tempfile = @service.send(:image_tempfile, "1234")
        assert tempfile.is_a?(Tempfile)
        assert_equal "image data", tempfile.read
      end
    end

    def test_image_tempfile_with_nil_image_data
      @service.stub :image_data, nil do
        tempfile = @service.send(:image_tempfile, "1234")
        assert_nil tempfile
      end
    end

    def test_attach_io_with_image_content_type
      tempfile = Tempfile.new("test")
      tempfile.write("image data")
      tempfile.rewind

      Marcel::MimeType.stub :for, "image/jpeg" do
        asset = Minitest::Mock.new
        asset.expect :parent_id=, nil, ["1234"]
        asset.expect :file=, nil, [tempfile]
        asset.expect :title=, nil, [String]
        asset.expect :thumbnail=, nil, [true]
        asset.expect :save, true

        Asset.stub :new, asset do
          @document.thumbnail_state_machine.expect :transition_to!, nil, [:succeeded, Hash]
          @service.send(:attach_io, tempfile)
        end
      end
    end

    def test_attach_io_with_non_image_content_type
      tempfile = Tempfile.new("test")
      tempfile.write("non-image data")
      tempfile.rewind

      Marcel::MimeType.stub :for, "application/pdf" do
        @document.thumbnail_state_machine.expect :transition_to!, nil, [:placeheld, Hash]
        @service.send(:attach_io, tempfile)
      end
    end

    def test_remote_image_with_valid_url
      Faraday.stub :new, Minitest::Mock.new do
        conn = Faraday.new
        conn.stub :get, OpenStruct.new(body: "image data") do
          @service.stub :image_url, "http://example.com/image.jpg" do
            assert_equal "image data", @service.send(:remote_image)
          end
        end
      end
    end

    def test_remote_image_with_invalid_url
      Faraday.stub :new, Minitest::Mock.new do
        conn = Faraday.new
        conn.stub :get, nil do
          @service.stub :image_url, "invalid_url" do
            assert_nil @service.send(:remote_image)
          end
        end
      end
    end

    def test_image_url
      assert_equal "http://example.com/thumbnail.jpg", @service.send(:image_url)
    end

    def test_log_output
      logger = Minitest::Mock.new
      logger.expect :tagged, nil, ["1234", "solr_doc_id"]
      logger.expect :tagged, nil, ["1234", "placeheld"]

      ActiveSupport::TaggedLogging.stub :new, logger do
        @service.send(:log_output)
      end
    end
  end
end
