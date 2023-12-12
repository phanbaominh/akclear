# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Clear
    can :read, Channel

    return if user.blank?

    can :create, Clear
    can :update, Clear, submitter: user, verification: { status: Verification::DECLINED }

    can %i[create destroy], :like
    can %i[create destroy], :report

    return unless user.verifier? || user.admin?

    can %i[create], Verification
    can %i[update destroy], Verification, verifier: user # TODO: allow other users to edit too? (if clear is flagged)

    return unless user.admin?

    can :manage, :all
    cannot :edit, User, id: user.id
  end
end
