require 'rails_helper'

describe User do
  describe '#role' do
    it { is_expected.to define_enum_for(:role).with_values(%i[user verifier admin]) }
  end
end
