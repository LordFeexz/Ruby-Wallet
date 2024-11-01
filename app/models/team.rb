class Team < ApplicationRecord
  belongs_to :user, foreign_key: :owner_id

  validates :owner_id, presence: true
  validates :name, presence: true,  length: { in: 3..20 }, allow_nil: false
  validate :unique_name

  private

  def unique_name
    if Team.exists?(name: name)
      errors.add(:name, "already exists")
      raise ConflictError, "Name already exists"
    end
  end
end
