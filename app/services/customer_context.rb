class CustomerContext
  def self.for(phone:, message:)
    new(phone:, message:).to_h
  end

  def initialize(phone:, message:)
    @phone = PhoneNumber.normalize(phone)
    @message = message.to_s
  end

  def to_h
    customer = Customer.includes(:orders).find_by(phone_e164: @phone)

    {
      request: {
        from_phone_e164: @phone,
        text: @message
      },
      matched_customer: customer.present?,
      customer: serialize_customer(customer),
      available_actions: [
        "answer questions using this Rails-provided customer/order context",
        "summarize order status",
        "ask a clarifying question when the Rails data is insufficient",
        "escalate to a human if the request needs private data or an unsupported action"
      ]
    }
  end

  private

  def serialize_customer(customer)
    return nil unless customer

    {
      name: customer.name,
      phone_e164: customer.phone_e164,
      email: customer.email,
      tier: customer.tier,
      notes: customer.notes,
      orders: customer.orders.order(created_at: :desc).map do |order|
        {
          external_id: order.external_id,
          status: order.status,
          total: order.total,
          summary: order.summary,
          created_at: order.created_at&.iso8601
        }
      end
    }
  end
end
