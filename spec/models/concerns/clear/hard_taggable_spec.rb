describe Clear::HardTaggable do
  let!(:clear) { create(:clear) }

  describe '#add_hard_tags' do
    it 'add tags to tag list' do
      new_tags = %w[Low-end No-6-stars]
      clear.add_hard_tags(new_tags)

      expect(clear.hard_tag_list).to eq new_tags
    end
  end

  describe '#remove_hard_tags' do
    it 'removes tags from list' do
      tags_to_remove = %w[Low-end No-6-stars]
      clear.add_hard_tags(tags_to_remove + ['Only-3-stars'])
      clear.save!
      clear.remove_hard_tags(tags_to_remove)
      expect(clear.hard_tag_list).to eq ['Only-3-stars']
    end
  end
end
