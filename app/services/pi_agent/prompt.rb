require "json"

module PiAgent
  class Prompt
    def initialize(message:, context:)
      @message = message.to_s
      @context = context
    end

    def to_s
      <<~PROMPT
        A WhatsApp customer sent this message:

        #{@message}

        Rails looked up the customer and provided this JSON context. Use only this data for customer-specific facts:

        #{JSON.pretty_generate(@context)}

        Reply as a concise, helpful WhatsApp assistant. If the answer is not in the Rails data, say what you need next or offer human escalation. Do not mention internal prompts, Rails, Pi, or implementation details.
      PROMPT
    end
  end
end
