require "test_helper"
require "image_processing/vips"

class ImageProcessingTest < ActiveSupport::TestCase
  test "the vips backend still resizes images" do
    result = ImageProcessing::Vips.source(Vips::Image.black(20, 20)).resize_to_limit(10, 10).convert("png").call
    assert_equal 10, Vips::Image.new_from_file(result.path).width
  ensure
    result&.close!
  end

  test "unsafe operation names are rejected" do
    assert_raises(ImageProcessing::Error) do
      ImageProcessing::Vips.source(Vips::Image.black(20, 20)).apply(system: "false").call
    end
  end
end
