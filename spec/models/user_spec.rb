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

    let(:abilities_dict) do
      {
        read_clear: [Clear, :read],
        read_channel: [Channel, :read],
        like: [:like, %i[create destroy]],
        create_clear: [Clear, :create],
        update_submitted_clear: [submitted_clear, :update],
        update_rejected_submitted_clear: [rejected_submitted_clear, :update],
        report: [:report, %i[create destroy]],
        create_verification_with_no_channel: [Verification.new(clear: Clear.new), %i[create]],
        create_verification_with_channel: [verification_with_channel, %i[create]],
        change_verification: [verification, %i[update destroy]],
        change_self_verification: [self_verification, %i[update destroy]],
        all: %i[all manage],
        create_and_destroy_channel: [Channel, %i[create destroy]],
        edit_user: [other_user, :edit],
        edit_self: [user, :edit]
      }
    end

    shared_examples 'has abilities' do
      let(:submitted_clear) { build(:clear, submitter: user || build(:user)) }
      let(:rejected_submitted_clear) { create(:clear, :rejected, submitter: user || build(:user)) }
      let(:clear_with_channel) { create(:clear) }
      let(:verification_with_channel) { create(:verification, clear: clear_with_channel) }
      let(:verification) { build(:verification) }
      let(:self_verification) { build(:verification, verifier: user || build(:user)) }
      let(:other_user) { build(:user) }

      it 'has abilities' do
        abilities_dict.each do |ability, (resource, actions)|
          if abilities.include?(ability)
            Array(actions).each { |action| is_expected.to be_able_to(action, resource) }
          else
            Array(actions).each { |action| is_expected.not_to be_able_to(action, resource) }
          end
        end
      end
    end

    context 'when user is guest' do
      let(:abilities) do
        %i[read_clear read_channel]
      end

      it_behaves_like 'has abilities'
    end

    context 'when user is logged in' do
      let_it_be(:user) { create(:user) }
      let(:abilities) do
        %i[
          read_clear read_channel create_clear update_rejected_submitted_clear like report
        ]
      end

      it_behaves_like 'has abilities'
    end

    context 'when user is verifier' do
      let_it_be(:user) { create(:verifier) }

      let(:abilities) do
        %i[
          read_clear read_channel create_clear update_rejected_submitted_clear like report
          create_verification_with_channel change_self_verification create_and_destroy_channel
        ]
      end

      it_behaves_like 'has abilities'
    end

    context 'when user is admin' do
      let_it_be(:user) { create(:admin) }

      let(:abilities) do
        %i[
          read_clear read_channel create_clear update_submitted_clear update_rejected_submitted_clear like report
          create_verification_with_channel create_verification_with_no_channel change_verification change_self_verification
          all edit_user create_and_destroy_channel
        ]
      end

      it_behaves_like 'has abilities'
    end
  end
end
