class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :phone_e164, presence: true
  validates :phone_e164, uniqueness: true

  before_validation :normalize_phone

  private

  def normalize_phone
    self.phone_e164 = PhoneNumber.normalize(phone_e164) if phone_e164.present?
  end
end
