class User < ApplicationRecord
  include User::Likeable
  include User::Verifiable
  has_secure_password

  ROLES = %i[user verifier admin].freeze

  enum :role, ROLES, default: :user

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 1 }, format: { with: /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/ }

  before_validation do
    self.email = email.try(:downcase).try(:strip)
  end

  before_validation if: :email_changed? do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).destroy_all
  end
end
