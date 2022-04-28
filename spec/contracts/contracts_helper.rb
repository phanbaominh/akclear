# frozen_string_literal: true

RSpec.shared_context 'contract' do
  let(:service) { described_class.new }
  let(:result) { service.call(params) }
  let(:context) { result.context }
  let(:errors) { result.errors }
end

RSpec.shared_examples 'schema field' do |field_name, failures:, valid_value:, required: false|
  describe "f.#{field_name}" do
    let(:params) { { field_name => send(field_name) } }

    failures.each do |failure|
      example_description = failure[1]
      context "when #{example_description}" do
        let(:error_message) { failure[2] }
        let(:field_value) { failure[0] }
        let(field_name) { field_value }

        it 'fails' do
          expect(errors[field_name]).to eq [error_message]
        end
      end
    end

    context 'when is valid' do
      let(field_name) { valid_value }

      it 'succeed' do
        expect(errors[field_name]).to be_nil
      end
    end

    if required
      context 'when is missing' do
        let(:params) { {} }

        specify { expect(errors[field_name]).to eq ['is missing'] }
      end
    end
  end
end
