require "test_helper"

class AgentMessagesTest < ActionDispatch::IntegrationTest
  test "returns an agent reply with Rails customer context" do
    post api_v1_agent_messages_path, params: {
      from: "+15551234567",
      text: "Where is my order?"
    }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "deterministic", body.fetch("agent_mode")
    assert_includes body.fetch("reply"), "POC-1001"
    assert_equal true, body.dig("context", "matched_customer")
  end

  test "handles an unknown WhatsApp sender" do
    post api_v1_agent_messages_path, params: {
      from: "+15550000000",
      text: "Where is my order?"
    }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_includes body.fetch("reply"), "could not find"
  end
end
