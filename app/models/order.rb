class Order < ApplicationRecord
  belongs_to :customer

  validates :external_id, :status, :currency, presence: true
  validates :external_id, uniqueness: true

  def total
    format("%.2f %s", total_cents.to_i / 100.0, currency)
  end
end
