require 'rails_helper'

RSpec.describe Clear do
  describe 'associations' do
    it { is_expected.to belong_to(:submitter) }
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:channel).optional }
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
    let_it_be(:clear, reload: true) { create(:clear) }
    let(:link) { 'https://youtube.com/watch?v=123' }

    before { allow(Clears::AssignChannelJob).to receive(:perform_later) }

    context 'when clear is new and already has a channel' do
      it 'does not assign the channel' do
        clear = build(:clear)
        clear.channel = build(:channel)

        clear.update!(link:, updated_at: Time.current)

        expect(Clears::AssignChannelJob).not_to have_received(:perform_later)
      end
    end

    context 'when the link has changed' do
      it 'runs assigns the channel job' do
        clear.link = link

        clear.save!

        expect(Clears::AssignChannelJob).to have_received(:perform_later).with(clear.id, link)
      end
    end

    context 'when the link has not changed' do
      it 'does not assign the channel' do
        clear.update!(updated_at: Time.current)

        expect(Clears::AssignChannelJob).not_to have_received(:perform_later)
      end
    end
  end

  describe '#created_by_trusted_users?' do
    context 'when the submitter is a verifier' do
      it 'returns true' do
        clear = build(:clear, submitter: build(:user, :verifier))

        expect(clear.created_by_trusted_users?).to eq(true)
      end
    end

    context 'when the submitter is an admin' do
      it 'returns true' do
        clear = build(:clear, submitter: build(:user, :admin))

        expect(clear.created_by_trusted_users?).to eq(true)
      end
    end

    context 'when the submitter is a regular user' do
      it 'returns false' do
        clear = build(:clear, submitter: build(:user))

        expect(clear.created_by_trusted_users?).to eq(false)
      end
    end
  end
end
