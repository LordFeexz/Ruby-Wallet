class TopupProp
  include ActiveModel::Model
  attr_accessor :amount

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
