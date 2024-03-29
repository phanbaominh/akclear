require 'rails_helper'
require 'support/shared_examples/invalid_video'

describe Clears::BuildClearFromVideo do
  let_it_be(:stage) { create(:stage) }
  let_it_be(:operator) { create(:operator) }
  let(:used_operators_attributes) do
    [{ operator_id: operator.id, level: 50, elite: 2, skill: 1 }]
  end
  let(:result) { described_class.call(video, operator_name_only: true, languages: [:jp]) }

  before do
    allow(Clears::GetClearImageFromVideo).to receive(:call).and_return(Dry::Monads::Success('image_path'))
    allow(ClearImage).to receive(:new)
      .and_return(instance_double(ClearImage, used_operators_data: used_operators_attributes))
  end

  include_examples 'invalid video'

  context 'when video is valid' do
    let(:video) { Video.new(video_url) }
    let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34s' }

    it 'builds clear' do
      clear = result.value!
      expect(Clears::GetClearImageFromVideo).to have_received(:call).with(video)
      expect(ClearImage).to have_received(:new).with('image_path', { global: { operator_name_only: true } },
                                                     possible_languages: [:jp])
      expect(clear).to have_attributes(
        {
          link: 'https://youtube.com/watch?v=aAfeBGKoZeI',
          used_operators: [have_attributes(used_operators_attributes.first)]
        }
      )
    end
  end
end
