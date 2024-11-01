class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :password_digest, presence: true
end
