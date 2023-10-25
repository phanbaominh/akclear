# frozen_string_literal: true

class Verification < ApplicationRecord
  belongs_to :verifier, class_name: 'User'
  belongs_to :clear

  has_many :used_operator_verifications, dependent: :destroy

  accepts_nested_attributes_for :used_operator_verifications

  STATUSES = [
    DECLINED = 'declined',
    ACCEPTED = 'accepted'
  ].freeze

  enum :status, { DECLINED => 0, ACCEPTED => 1 }

  validates :status, inclusion: { in: STATUSES }, presence: true
  validates :comment, length: { maximum: 1000 }

  def acceptable?
    used_operator_verifications.all?(&:accepted?) && used_operator_verifications.size == clear.used_operators.size
  end

  def declineable?
    used_operator_verifications.any?(&:declined?)
  end
end
