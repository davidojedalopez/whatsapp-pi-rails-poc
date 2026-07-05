module Webhooks
  class WhatsappController < ApplicationController
    def verify
      if params["hub.mode"] == "subscribe" && secure_compare(params["hub.verify_token"], webhook_verify_token)
        render plain: params["hub.challenge"]
      else
        head :forbidden
      end
    end

    def create
      payload = Whatsapp::WebhookPayload.new(params.to_unsafe_h)
      sender = Whatsapp::Sender.new

      payload.messages.each do |message|
        next unless authorized_sender?(message.from)

        context = CustomerContext.for(phone: message.from, message: message.text)
        agent_result = PiAgent::Client.new.reply(message: message.text, context:)
        sender.send_text(to: message.from, body: agent_result.text)
      end

      render json: { status: "ok", processed: payload.messages.count }
    end

    private

    def webhook_verify_token
      ENV.fetch("WHATSAPP_WEBHOOK_VERIFY_TOKEN", "dev-verify-token")
    end

    def secure_compare(left, right)
      ActiveSupport::SecurityUtils.secure_compare(left.to_s, right.to_s)
    rescue ArgumentError
      false
    end

    def authorized_sender?(phone)
      allowed = ENV["WHATSAPP_ALLOWED_SENDERS"].to_s.split(",").map { |value| PhoneNumber.normalize(value) }.compact
      return true if allowed.empty?

      allowed.include?(PhoneNumber.normalize(phone))
    end
  end
end
