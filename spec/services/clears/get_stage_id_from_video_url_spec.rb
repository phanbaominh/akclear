require 'rails_helper'

describe Clears::GetStageIdFromVideoUrl do
  let_it_be(:stage) { create(:stage, code: 'CODE', game_id: 'gameid') }
  let_it_be(:challenge_mode_stage) { create(:stage, code: 'CODE', game_id: '#f#gameid') }
  let_it_be(:wrong_code_stage) { create(:stage, code: 'WRONG', game_id: 'wgameid') }
  let(:link) { 'https://www.youtube.com/watch?v=123&' }
  let(:video_data) { double(title: 'CODE | title') }

  before do
    allow(Yt::Video).to receive(:new).and_return(video_data)
  end

  it 'returns the stage with correct code' do
    expect(described_class.call(link).value!).to eq(stage.id)
    expect(Yt::Video).to have_received(:new).with(url: link)
  end
end
