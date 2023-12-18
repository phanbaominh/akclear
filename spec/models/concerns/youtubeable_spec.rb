require 'rails_helper'

describe Youtubeable do
  let_it_be(:clear) { build_stubbed(:clear, link: 'https://www.youtube.com/watch?v=B9zJ2T8mCWk') }

  describe '#embed_link' do
    it 'returns the embed link' do
      expect(clear.embed_link).to eq('https://youtube.com/embed/B9zJ2T8mCWk')
    end
  end
end
