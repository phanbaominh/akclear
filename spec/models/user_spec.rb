require 'rails_helper'
require 'cancan/matchers'

describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { expect(create(:user)).to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to validate_length_of(:password).is_at_least(12) }
    it { expect(create(:user)).to validate_uniqueness_of(:username) }
    it { is_expected.to validate_length_of(:username).is_at_most(20).is_at_least(3) }
  end

  describe '#role' do
    it { is_expected.to define_enum_for(:role).with_values(%i[user verifier admin]) }
  end

  describe 'abilities' do
    subject { Ability.new(user) }

    let_it_be(:user) { nil }

    context 'when user is guest' do
      it { is_expected.not_to be_able_to(:create, :like) }
      it { is_expected.not_to be_able_to(:destroy, :like) }
      it { is_expected.not_to be_able_to(:create, Verification.new) }
      it { is_expected.not_to be_able_to(:destroy, Verification.new) }
    end

    context 'when user is logged in' do
      let_it_be(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, :like) }
      it { is_expected.to be_able_to(:destroy, :like) }
      it { is_expected.not_to be_able_to(:create, Verification.new) }
      it { is_expected.not_to be_able_to(:destroy, Verification.new) }
    end

    context 'when user is verifier' do
      let_it_be(:user) { create(:verifier) }

      it { is_expected.to be_able_to(:create, :like) }
      it { is_expected.to be_able_to(:destroy, :like) }
      it { is_expected.to be_able_to(:create, Verification.new) }
      it { is_expected.to be_able_to(:destroy, Verification.new(verifier: user)) }
    end

    context 'when user is admin' do
      let_it_be(:user) { create(:admin) }

      it { is_expected.to be_able_to(:create, :like) }
      it { is_expected.to be_able_to(:destroy, :like) }
      it { is_expected.to be_able_to(:create, Verification.new) }
      it { is_expected.to be_able_to(:destroy, Verification.new) }
    end
  end
end
