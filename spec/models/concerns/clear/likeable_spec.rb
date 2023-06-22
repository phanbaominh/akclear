require 'rails_helper'

describe Clear::Likeable do
  let_it_be(:clear, reload: true) { create(:clear) }

  describe 'associations' do
    subject { clear }

    it { is_expected.to have_and_belong_to_many(:likers).class_name('User').join_table(:likes) }
  end

  describe '#likes' do
    let_it_be(:user) { create(:user) }

    it 'returns the number of users who liked the clear' do
      expect { user.like(clear) }.to change(clear, :likes_count).by(1)
    end
  end
end
