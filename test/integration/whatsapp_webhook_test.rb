require "test_helper"

class WhatsappWebhookTest < ActionDispatch::IntegrationTest
  test "verifies the WhatsApp webhook challenge" do
    get "/webhooks/whatsapp", params: {
      "hub.mode" => "subscribe",
      "hub.verify_token" => "dev-verify-token",
      "hub.challenge" => "challenge-123"
    }

    assert_response :success
    assert_equal "challenge-123", response.body
  end

  test "rejects an invalid WhatsApp verification token" do
    get "/webhooks/whatsapp", params: {
      "hub.mode" => "subscribe",
      "hub.verify_token" => "wrong",
      "hub.challenge" => "challenge-123"
    }

    assert_response :forbidden
  end

  test "processes inbound text messages" do
    post "/webhooks/whatsapp", params: whatsapp_payload, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "ok", body.fetch("status")
    assert_equal 1, body.fetch("processed")
  end

  private

  def whatsapp_payload
    {
      object: "whatsapp_business_account",
      entry: [
        {
          id: "waba-id",
          changes: [
            {
              field: "messages",
              value: {
                messaging_product: "whatsapp",
                metadata: {
                  display_phone_number: "15557654321",
                  phone_number_id: "phone-number-id"
                },
                contacts: [
                  {
                    profile: { name: "David" },
                    wa_id: "15551234567"
                  }
                ],
                messages: [
                  {
                    from: "15551234567",
                    id: "wamid.test",
                    timestamp: "1720000000",
                    text: { body: "Where is my order?" },
                    type: "text"
                  }
                ]
              }
            }
          ]
        }
      ]
    }
  end
end
