class AssetUploader < Kithe::AssetUploader
  # gives us md5, sha1, sha512
  plugin :kithe_checksum_signatures

  THUMB_WIDTHS = {
    mini: 54,
    large: 525,
    standard: 208
  }

  # define thumb derivatives for TIFF, PDF, and other image input: :thumb_mini, :thumb_mini_2X, etc.
  THUMB_WIDTHS.each_pair do |key, width|
    # Single-width thumbnails
    Attacher.define_derivative("thumb_#{key}", content_type: "image") do |original_file|
      Kithe::VipsCliImageToJpeg.new(max_width: width, thumbnail_mode: true).call(original_file)
    end

    # Double-width thumbnails
    Attacher.define_derivative("thumb_#{key}_2X", content_type: "image") do |original_file|
      Kithe::VipsCliImageToJpeg.new(max_width: width * 2, thumbnail_mode: true).call(original_file)
    end
  end

  # and a full size jpg
  Attacher.define_derivative("download_full", content_type: "image") do |original_file, attacher:|
    # No need to do this if our original is a JPG
    unless attacher.file.content_type == "image/jpeg"
      Kithe::VipsCliImageToJpeg.new.call(original_file)
    end
  end
end
