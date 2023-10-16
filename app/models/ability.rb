# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can %i[create destroy], :like

    return unless user.verifier? || user.admin?

    can %i[create destroy], :verification

    return unless user.admin?

    can :manage, :all
    cannot :edit, User, id: user.id
  end
end
