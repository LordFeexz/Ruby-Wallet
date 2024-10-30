class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :password_digest, presence: true

  validate :password_complexity

  private

  def password_complexity
    unless password =~ /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])/
      errors.add(:password_digest, "must include at least one lowercase letter, one uppercase letter, one digit, and one special character")
    end
  end
end
