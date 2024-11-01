class CredentialProp
  include ActiveModel::Model
  attr_accessor :username, :password

  validates :username, presence: true, length: { in: 3..20 }, allow_nil: false
  validates :password, presence: true

  validate :password_complexity

  private

  def password_complexity
    unless password =~ /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])/
      errors.add(:password_digest, "must include at least one lowercase letter, one uppercase letter, one digit, and one special character")
    end
  end
end
