require 'rails_helper'

describe Clear::Likeable do
  describe 'associations' do
    subject { build_stubbed(:clear) }

    it { is_expected.to have_and_belong_to_many(:likers).class_name('User').join_table(:likes) }
  end
end
