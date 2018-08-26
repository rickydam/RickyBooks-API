class User < ApplicationRecord
  has_many :textbooks
  has_many :notify_items, dependent: :destroy

  has_secure_password
  has_secure_token

  before_save :downcase_email

  validates :name,
            presence: true,
            length: { maximum: 50}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 70 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  # This method is not available in has_secure_token
  def invalidate_token
    update_columns(token: nil)
  end

  def invalidate_firebase_token
    update_columns(firebase_token: nil)
  end

  def self.valid_login?(email, password)
    user = find_by(email: email)
    if user && user.authenticate(password)
      user
    end
  end

  def downcase_email
    self.email = email.downcase
  end
end
