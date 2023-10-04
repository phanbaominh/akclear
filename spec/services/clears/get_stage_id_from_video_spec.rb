require 'rails_helper'
require 'support/shared_examples/invalid_video'

describe Clears::GetStageIdFromVideo do
  let_it_be(:stage) { create(:stage, code: 'CODE', game_id: 'gameid') }
  let_it_be(:challenge_mode_stage) { create(:stage, code: 'CODE', game_id: '#f#gameid') }
  let_it_be(:wrong_code_stage) { create(:stage, code: 'WRONG', game_id: 'wgameid') }
  let(:result) { described_class.call(video) }

  include_examples 'invalid video'

  context 'when video is valid' do
    let(:video) { instance_double(Video, title: 'CODE | title', valid?: true) }

    it 'returns the stage with correct code' do
      expect(result.value!).to eq(stage.id)
    end
  end
end
