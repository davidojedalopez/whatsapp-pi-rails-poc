module PiAgent
  class DeterministicReply
    def initialize(message:, context:)
      @message = message.to_s.downcase
      @context = context
      @customer = context[:customer] || context["customer"]
    end

    def call
      return unknown_customer unless @customer

      if @message.match?(/order|pedido|status|where|donde|tracking|track/)
        order_status
      elsif @message.match?(/hello|hi|hola|hey|help|ayuda/)
        greeting
      else
        general_summary
      end
    end

    private

    def unknown_customer
      "I could not find your customer record yet. Please share the email or order number you used, or I can route this to a human."
    end

    def greeting
      "Hi #{@customer[:name]} — I can help with your account or order status. What would you like to check?"
    end

    def order_status
      orders = @customer[:orders] || []
      return "Hi #{@customer[:name]} — I do not see any orders on your account yet. I can route this to a human if that seems wrong." if orders.empty?

      order = orders.first
      "Hi #{@customer[:name]} — your latest order #{order[:external_id]} is #{order[:status]}. #{order[:summary]} Total: #{order[:total]}."
    end

    def general_summary
      "Hi #{@customer[:name]} — I found your #{@customer[:tier]} account. Ask me about your order status, account notes, or request human support."
    end
  end
end
