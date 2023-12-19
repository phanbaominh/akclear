require 'rails_helper'

describe UsedOperatorsSession do
  let(:initial_session) { [] }
  let(:session) { described_class.new(initial_session) }

  def get_info(params)
    UsedOperatorsSession::Info.new(params).raw
  end

  describe '#init_from_clear' do
    let_it_be(:clear) { create(:clear) }
    let_it_be(:used_operator) do
      create(:used_operator, clear:)
    end

    it 'initializes session from clear' do
      clear.reload.used_operators.to_a.first.info = get_info(level: 50, elite: 2, skill: 1, skill_level: 7,
                                                             skill_mastery: 3, clear_id: clear.id, id: used_operator.id, operator_id: used_operator.operator_id)
      session.init_from_clear(clear)
      expect(session.data).to eq(
        [{ 'info' => get_info(operator_id: used_operator.operator_id, level: 50, elite: 2, skill: 1, skill_level: 7,
                              skill_mastery: 3, clear_id: clear.id, id: used_operator.id), 'id' => used_operator.id }]
      )
    end
  end

  describe '#add' do
    context 'when operator is not in session' do
      it 'adds operator to session' do
        session.add({ operator_id: 1 })
        expect(session.data).to eq([{ 'info' => get_info(operator_id: 1) }])
      end
    end

    context 'when operator is already in session' do
      let(:initial_session) { [{ 'info' => get_info('operator_id' => 1, 'clear_id' => 1, 'id' => 1), 'id' => 1 }] }

      it 'updates existing operator in session' do
        session.add({ operator_id: '1', level: '50' })
        expect(session.data).to eq(
          [{ 'info' => get_info(operator_id: '1', level: '50', clear_id: 1, id: 1), 'id' => 1 }]
        )
      end
    end
  end

  describe '#remove' do
    let(:initial_session) { [{ 'info' => get_info('operator_id' => 1, 'id' => 1), 'id' => 1 }] }

    it 'marks operator as destroyed' do
      session.remove('1')
      expect(session.data).to eq(
        [{ 'info' => get_info(operator_id: 1, id: 1), '_destroy' => true, 'id' => 1 }]
      )
    end
  end

  describe '#update' do
    let(:initial_session) { [{ 'info' => get_info('operator_id' => 1, 'id' => 1) }] }

    it 'updates operator in session' do
      session.update({ operator_id: '1', level: '50', id: '1' })
      expect(session.data).to eq(
        [{ 'info' => get_info(operator_id: '1', level: '50', id: '1'), 'id' => '1' }]
      )
    end
  end
end
