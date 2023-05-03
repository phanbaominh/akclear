require 'rails_helper'

describe Clear::Specification do
  let_it_be(:event) { create(:event) }
  let_it_be(:operator) { create(:operator) }
  let_it_be(:stage) { create(:stage) }
  let(:options) do
    {
      stageable_id: event.to_global_id.to_s,
      stage_id: stage.id,
      operator_id: operator.id,
      used_operators_attributes: { '0' => { operator_id: operator.id } },
      challenge_mode: true
    }
  end

  it 'inits correctly' do
    spec = described_class.new(
      **options
    )

    expect(spec).to have_attributes(
      stageable: event,
      stage:,
      used_operators: [an_object_having_attributes(operator_id: operator.id, class: UsedOperator)]
    )
  end
end
