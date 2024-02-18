require 'rails_helper'

describe ExtractClearResultImporter do
  it 'imports non-existing channels and clear jobs' do
    stage_1 = create(:stage, game_id: '1')
    stage_2 = create(:stage, game_id: '2')
    existing_channel = create(:channel, external_id: '1')
    new_channel = create(:channel, external_id: '2')

    existing_job = # rubocop:disable Lint/UselessAssignment
      create(:extract_clear_data_from_video_job, status: :completed, channel: existing_channel, stage: stage_1)
    incompleted_job = create(:extract_clear_data_from_video_job, channel: existing_channel, stage: stage_2)
    new_job_1 =
      create(:extract_clear_data_from_video_job, status: :completed, channel: existing_channel, stage: stage_1)
    new_job_2 = create(:extract_clear_data_from_video_job, status: :completed, channel: new_channel, stage: stage_2)

    Tempfile.create('export.txt') do |file|
      ExtractClearResultExporter.new.export(file)
      file.rewind

      incompleted_job.destroy
      new_job_2.destroy
      new_channel.destroy
      new_job_1.destroy

      expect do
        ExtractClearResultImporter.new(file:).import
      end.to change(Channel,
                    :count).by(1).and(change(ExtractClearDataFromVideoJob, :count).by(2))

      expect(ExtractClearDataFromVideoJob.find_by(
               **new_job_1.attributes.slice('stage_id', 'channel_id', 'data', 'video_url')
             ))
        .to be_present
      expect((new_imported_channel = Channel.find_by(external_id: new_channel.external_id))).to be_present
      expect(ExtractClearDataFromVideoJob.find_by(
               **new_job_2.attributes.slice('stage_id', 'data', 'video_url').merge(channel_id: new_imported_channel.id)
             ))
        .to be_present
    end
  end
end
