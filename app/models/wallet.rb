class Wallet < ApplicationRecord
  validates :reference_id, presence: true, uniqueness: true, length: { minimum: 1 }
  validates :reference_type, presence: true, acceptance: { accept: [ "user", "team" ] }

  attribute :balance, :decimal, default: 0.0
end
