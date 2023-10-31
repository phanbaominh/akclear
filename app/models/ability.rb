# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Clear

    return if user.blank?

    can :create, Clear
    can :edit, Clear, submitter: user, verification: { status: Verification::DECLINED }

    can %i[create destroy], :like

    return unless user.verifier? || user.admin?

    can %i[create destroy], Verification

    return unless user.admin?

    can :manage, :all
    cannot :edit, User, id: user.id
  end
end
