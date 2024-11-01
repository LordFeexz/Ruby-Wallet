class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, inclusion: { in: [ "credit", "debit" ], message: "%{value} is not a valid transaction type" }
  validates :description, length: { maximum: 255 }, allow_nil: true

  after_initialize :set_default_context, if: :new_record?

  private

  def set_default_context
    self.context ||= {}
  end
end
