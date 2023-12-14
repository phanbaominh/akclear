class UsedOperatorVerification < ApplicationRecord
  belongs_to :verification
  belongs_to :used_operator

  enum :status, { Verification::REJECTED => 0, Verification::ACCEPTED => 1 }
  validates :status, inclusion: { in: Verification::STATUSES }, presence: true
end
