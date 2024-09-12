# frozen_string_literal: true

require "test_helper"

class AssetUploaderTest < ActiveSupport::TestCase
  setup do
    # Mocking Settings.GBL_ADMIN_THUMBNAIL_WIDTHS to simulate thumbnail width settings
    @thumb_widths = {mini: 100, small: 200}
    Settings.stub(:GBL_ADMIN_THUMBNAIL_WIDTHS, @thumb_widths) do
      @uploader = AssetUploader.new(:store)
      @original_file = Tempfile.new(["image", ".png"]) # Mock an original image file for testing
      @original_file.write("fake image content") # Add fake content to simulate an image
      @original_file.rewind

      @attacher = @uploader.class::Attacher.from_data({})
    end
  end

  test "defines single-width and double-width thumbnails correctly" do
    @thumb_widths.each do |key, width|
      # Define derivatives directly
      single_derivative = @uploader.derivatives(@original_file)[:derivatives]["thumb_#{key}"]
      double_derivative = @uploader.derivatives(@original_file)[:derivatives]["thumb_#{key}_2X"]

      # Test single-width thumbnail derivative
      assert single_derivative, "Expected single-width thumbnail 'thumb_#{key}' to be defined"
      assert_equal width, Kithe::VipsCliImageToPng.new(max_width: width, thumbnail_mode: true).max_width

      # Test double-width thumbnail derivative
      assert double_derivative, "Expected double-width thumbnail 'thumb_#{key}_2X' to be defined"
      assert_equal width * 2, Kithe::VipsCliImageToPng.new(max_width: width * 2, thumbnail_mode: true).max_width
    end
  end

  test "defines download_full derivative correctly" do
    # Mocking the original file to have a non-JPEG content type
    def @attacher.file
      OpenStruct.new(content_type: "image/png")
    end

    # Define the download_full derivative directly
    full_derivative = @uploader.generate_derivatives(@original_file)[:derivatives]["download_full"]

    # Test that the derivative was created correctly
    assert full_derivative, "Expected download_full to be defined"
    converted_file = Kithe::VipsCliImageToPng.new.call(@original_file)
    assert_equal "image/png", converted_file.content_type
  end

  test "does not convert download_full if the original is a JPEG" do
    # Mocking the original file to have a JPEG content type
    def @attacher.file
      OpenStruct.new(content_type: "image/jpeg")
    end

    # Ensure no conversion is called for JPEGs
    Kithe::VipsCliImageToPng.stub(:new, -> { raise "Should not be called" }) do
      @uploader.generate_derivatives(@original_file)[:derivatives]["download_full"]
    end
  end
end
