module Whatsapp
  class WebhookPayload
    Message = Data.define(:from, :text, :message_id)

    def initialize(payload)
      @payload = payload.to_h
    end

    def messages
      entries.flat_map do |entry|
        Array(entry["changes"]).flat_map do |change|
          value = change.fetch("value", {})
          Array(value["messages"]).filter_map do |message|
            next unless message["type"] == "text"

            Message.new(
              from: PhoneNumber.normalize(message["from"]),
              text: message.dig("text", "body").to_s,
              message_id: message["id"]
            )
          end
        end
      end
    end

    private

    def entries
      Array(@payload["entry"])
    end
  end
end
