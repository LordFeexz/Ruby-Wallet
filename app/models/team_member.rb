class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validates :role, presence: true, inclusion: { in: [ 0, 1 ], message: "%{value} is not a valid role" }
end
