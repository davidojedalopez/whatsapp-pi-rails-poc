require "net/http"
require "json"

module Whatsapp
  class Sender
    GRAPH_VERSION = ENV.fetch("WHATSAPP_GRAPH_VERSION", "v23.0")

    def initialize(mode: ENV.fetch("WHATSAPP_SEND_MODE", "log"))
      @mode = mode
    end

    def send_text(to:, body:)
      case @mode
      when "log", "test"
        Rails.logger.info("WhatsApp reply to #{redacted(to)}: #{body}")
        { "mode" => @mode, "to" => PhoneNumber.whatsapp_id(to), "body" => body }
      when "cloud_api"
        post_cloud_api(to:, body:)
      else
        raise ArgumentError, "Unsupported WHATSAPP_SEND_MODE=#{@mode.inspect}"
      end
    end

    private

    def post_cloud_api(to:, body:)
      phone_number_id = ENV.fetch("WHATSAPP_PHONE_NUMBER_ID")
      access_token = ENV.fetch("WHATSAPP_ACCESS_TOKEN")
      uri = URI("https://graph.facebook.com/#{GRAPH_VERSION}/#{phone_number_id}/messages")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["Content-Type"] = "application/json"
      request.body = {
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to: PhoneNumber.whatsapp_id(to),
        type: "text",
        text: { preview_url: false, body: body.to_s.first(4_096) }
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.warn("WhatsApp Cloud API failed: status=#{response.code} body=#{response.body.to_s.truncate(500)}")
      end

      JSON.parse(response.body.presence || "{}")
    end

    def redacted(phone)
      digits = PhoneNumber.whatsapp_id(phone)
      return "[redacted]" if digits.blank?

      "***#{digits.last(4)}"
    end
  end
end
