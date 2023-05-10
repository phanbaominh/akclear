RSpec.shared_examples 'image_storable' do
  describe 'overwrite' do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
    end

    context 'when overwrite is true' do
      let(:service) { described_class.new(overwrite: true) }

      it 'overwrites existing images' do
        service.call

        expect(IO)
          .to have_received(:copy_stream)
          .with('image file', Regexp.new(overwritten_image_name))
      end
    end

    context 'when overwrite is false' do
      it 'does not overwrite existing images' do
        service.call

        expect(IO)
          .not_to have_received(:copy_stream)
          .with('image file', Regexp.new(overwritten_image_name))
      end
    end
  end
end
