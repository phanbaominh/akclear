require 'rails_helper'

describe User::Likeable do
  let_it_be(:user, reload: true) { create(:user) }

  describe 'associations' do
    subject { user }

    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:liked_clears).class_name('Clear').through(:likes).source(:clear) }
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
