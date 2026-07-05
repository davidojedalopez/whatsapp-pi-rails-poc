require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "shows POC status" do
    get root_path

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "WhatsApp Pi Rails POC", body.fetch("name")
    assert_equal "ok", body.fetch("status")
  end
end
