class Team < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 3..20 }
end
