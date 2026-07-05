Customer.destroy_all

customer = Customer.create!(
  name: "David",
  phone_e164: ENV.fetch("SEED_CUSTOMER_PHONE", "+15551234567"),
  email: "david@example.com",
  tier: "founder",
  notes: "POC test customer. Prefers short WhatsApp replies."
)

customer.orders.create!(
  external_id: "POC-1000",
  status: "delivered",
  total_cents: 1999,
  currency: "USD",
  summary: "Initial welcome kit"
)

customer.orders.create!(
  external_id: "POC-1001",
  status: "packed and ready to ship",
  total_cents: 4299,
  currency: "USD",
  summary: "Coffee sampler subscription box"
)

puts "Seeded #{Customer.count} customer(s) and #{Order.count} order(s)."
