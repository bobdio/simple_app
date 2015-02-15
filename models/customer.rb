class Customer < ActiveRecord::Base
  validates :firstname, :lastname, presence: true

  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 7 }
end