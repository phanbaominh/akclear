module Clear::Verifiable
  extend ActiveSupport::Concern

  included do
    has_one :verification, dependent: :destroy
    has_one :verifier, through: :verification

    after_create :mark_as_verified
    after_update -> { verification&.destroy }

    scope :unverified, -> { where.missing(:verification) }
    scope :verified, -> { joins(:verification) }
    scope :need_verification, lambda {
                                reported_verified_clears = Clear.verified.reported
                                if Current.ability
                                  reported_verified_clears = reported_verified_clears.merge(Verification.accessible_by(Current.ability, :update))
                                end
                                Clear.from("(#{[
                                  # should be .merge(Verification.accessible_by(Current.ability, :update)) instead of .joins
                                  # but it make the query to complex
                                  reported_verified_clears.joins(:channel).select(:id),
                                  Clear.unverified.joins(:channel).select(:id)
                                ].map(&:to_sql).join(' UNION ')}) clears").select(:id)
                              }

    attr_accessor :verification_status

    delegate :accepted?, :rejected?, to: :verification, allow_nil: true
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

  def rejected_used_operators
    used_operators.select(&:verification_rejected?)
  end

  def mark_as_verified
    return unless created_by_trusted_users?

    submitter.verify(self, { status: Verification::ACCEPTED, comment: I18n.t('clears.auto_verified_by_trusted_users') })
  end
end
