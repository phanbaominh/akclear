require 'rails_helper'

RSpec.describe Episode, type: :model do
  it { is_expected.to have_many(:stages).dependent(:nullify) }
end
