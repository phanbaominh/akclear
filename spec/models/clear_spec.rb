require 'rails_helper'

RSpec.describe Clear do
  describe 'associations' do
    it { is_expected.to belong_to(:submitter) }
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:channel) }
    it { is_expected.to have_many(:used_operators) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:link) }
  end

  describe '#mark_job_as_clear_created' do
    context 'when job_id is blank' do
      it 'returns' do
        allow(ExtractClearDataFromVideoJob).to receive(:find_by)

        create(:clear, job_id: nil)

        expect(ExtractClearDataFromVideoJob).not_to have_received(:find_by)
      end
    end

    context 'when job_id is present' do
      let_it_be(:job, reload: true) { create(:extract_clear_data_from_video_job) }

      context 'when job is completed' do
        it 'marks the job as clear_created' do
          job.update!(status: :completed)
          create(:clear, job_id: job.id)

          expect(job.reload).to be_clear_created
        end
      end

      context 'when job is not completed' do
        it 'does not mark the job as clear_created' do
          job.update!(status: :processing)
          create(:clear, job_id: job.id)

          expect(job.reload).not_to be_clear_created
        end
      end
    end
  end

  describe '#normalize_link' do
    context 'when the link has changed' do
      it 'normalizes the link when saving' do
        clear = build(:clear, link: 'https://youtu.be/aAfeBGKoZeI?t=34')

        clear.save!(validate: false)

        expect(clear.link).to eq('https://youtube.com/watch?v=aAfeBGKoZeI')
      end
    end
  end

  describe '#assign_channel' do
    context 'when the link has changed' do
      let(:link) { 'https://youtube.com/watch?v=123' }

      before { allow(Channel).to receive(:from).with(link).and_return(channel) }

      context 'when new channel' do
        let_it_be(:channel) { build(:channel) }

        it 'assigns the channel' do
          clear = build(:clear, link:, channel: nil)

          clear.save!

          expect(channel).to be_persisted
          expect(clear.channel).to eq(channel)
        end
      end

      context 'when existing channel' do
        let_it_be(:channel) { create(:channel) }

        it 'assigns the channel' do
          clear = build(:clear, link:, channel: nil)

          clear.save!

          expect(clear.channel).to eq(channel)
        end
      end
    end

    context 'when the link has not changed' do
      it 'does not assign the channel' do
        allow(Channel).to receive(:from)
        clear = create(:clear)

        clear.update!(updated_at: Time.current)

        expect(Channel).not_to have_received(:from)
      end
    end
  end
end
