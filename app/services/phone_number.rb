module PhoneNumber
  module_function

  def normalize(value)
    digits = value.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    "+#{digits}"
  end

  def whatsapp_id(value)
    normalize(value).to_s.delete_prefix("+")
  end
end
