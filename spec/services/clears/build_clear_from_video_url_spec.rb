require 'rails_helper'

describe Clears::BuildClearFromVideoUrl do
  let_it_be(:stage) { create(:stage) }
  let_it_be(:operator) { create(:operator) }
  let_it_be(:submitter) { create(:user) }
  let(:used_operators_attributes) do
    [{ operator_id: operator.id, level: 50, elite: 2, skill: 1 }]
  end
  let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34s' }

  before do
    allow(Clears::GetClearImageFromVideoUrl).to receive(:call).and_return(Dry::Monads::Success('image_path'))
    allow(Clears::BuildUsedOperatorsAttrsFromImage).to receive(:call)
      .and_return(Dry::Monads::Success(used_operators_attributes))
    allow(Clears::GetStageIdFromVideoUrl).to receive(:call).and_return(Dry::Monads::Success(stage.id))
  end

  it 'builds clear' do
    clear = described_class.call(video_url, submitter).value!
    expect(Clears::GetClearImageFromVideoUrl).to have_received(:call).with(video_url)
    expect(Clears::BuildUsedOperatorsAttrsFromImage).to have_received(:call).with('image_path')
    expect(Clears::GetStageIdFromVideoUrl).to have_received(:call).with(video_url)
    expect(clear).to have_attributes(
      {
        stage_id: stage.id,
        link: video_url,
        submitter:,
        used_operators: [have_attributes(used_operators_attributes.first)]
      }
    )
  end
end
