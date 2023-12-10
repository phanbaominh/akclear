module Clear::Verifiable
  extend ActiveSupport::Concern

  included do
    has_one :verification, dependent: :destroy
    has_one :verifier, through: :verification

    after_update -> { verification&.destroy }

    scope :unverified, -> { where.missing(:verification) }
    scope :verified, -> { joins(:verification) }
    scope :need_verification, lambda {
                                Clear.from("(#{[
                                  Clear.verified.reported.select(:id),
                                  Clear.unverified.select(:id)
                                ].map(&:to_sql).join(' UNION ')}) clears").select(:id)
                              }

    attr_accessor :verification_status

    delegate :accepted?, :declined?, to: :verification, allow_nil: true
  end

  def next_unverified
    self.class.need_verification.where(id: (id + 1..)).order(:id).first
  end

  def prev_unverified
    self.class.need_verification.where(id: (..id - 1)).order(id: :desc).first
  end

  def other_unverified
    next_unverified || prev_unverified
  end

  def verified?
    verification.present?
  end

  def accepted_used_operators
    used_operators.select(&:verification_accepted?)
  end

  def declined_used_operators
    used_operators.select(&:verification_declined?)
  end
end
