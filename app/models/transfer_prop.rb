class TransferProp
  include ActiveModel::Model

  attr_accessor :to, :amount, :text

  validates :to, presence: true, numericality: { greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :text, length: { maximum: 255 }, allow_nil: true
end
