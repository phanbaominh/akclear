require 'rails_helper'

describe User::Likeable do
  let_it_be(:user, reload: true) { create(:user) }

  describe 'associations' do
    subject { user }

    it { is_expected.to have_and_belong_to_many(:liked_clears).class_name('Clear').join_table(:likes) }
  end

  describe '#like' do
    let_it_be(:clear) { create(:clear) }

    it 'adds the clear to the user\'s liked clears' do
      expect { user.like(clear) }.to change { user.liked_clears.count }.by(1)
    end
  end

  describe '#unlike' do
    let_it_be(:clear) { create(:clear) }

    it 'removes the clear from the user\'s liked clears' do
      user.like(clear)

      expect { user.unlike(clear) }.to change { user.liked_clears.count }.by(-1)
    end
  end
end
