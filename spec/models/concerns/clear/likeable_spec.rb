require 'rails_helper'

describe Clear::Likeable do
  let_it_be(:clear, reload: true) { create(:clear) }

  describe 'associations' do
    subject { clear }

    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:likers).class_name('User').through(:likes).source(:user) }
  end

  describe '#likes' do
    let_it_be(:user) { create(:user) }

    it 'returns the number of users who liked the clear' do
      user.like(clear)
      expect(clear.reload.likes_count).to eq(1)
    end
  end
end
