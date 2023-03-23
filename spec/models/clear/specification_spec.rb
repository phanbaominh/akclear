require 'rails_helper'

describe Clear::Specification do
  let_it_be(:event) { create(:event) }
  let(:options) do
    {
      stageable_id: event.id,
      stageable_type: 'Event',
      stage_id: '2',
      operator_ids: [1, '2', '3']
    }
  end

  it 'inits correctly' do
    spec = described_class.new(
      **options
    )

    expect(spec).to have_attributes(
      stageable_id: event.id,
      stageable_type: 'Event',
      stage_id: 2,
      operator_ids: [1, 2, 3]
    )
  end
end
