# frozen_string_literal: true

class ExtractClearResultImporter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :file
  attribute :file_data

  def import_later
    ImportClearExtractionResultJob.perform_later(file_data)
  end

  def import
    channels, extract_clear_jobs = build_data
    bulk_import_channels(process_channels(channels))
    bulk_import_extract_clear_data_from_video_jobs(process_jobs(extract_clear_jobs))
  end

  def build_data
    channels = []
    extract_clear_jobs = []
    file_data.each do |line|
      record = deserialize(line.strip)
      # should be converted to Factory pattern when more types are added
      # use Enumarator to lazily import the data
      case record
      when Channel
        channels << record
      when ExtractClearDataFromVideoJob
        extract_clear_jobs << record
      end
    end
    [channels, extract_clear_jobs]
  end

  def process_channels(channels)
    remove_existing_channels(channels)
  end

  def bulk_import_channels(channels)
    Channel.import!(channels, validate: true)
  end

  def remove_existing_channels(channels)
    existing_external_ids = Channel.where(external_id: channels.map(&:external_id)).pluck(:external_id)
    channels.reject { |channel| existing_external_ids.include?(channel.external_id) }
  end

  def process_jobs(jobs)
    jobs = remove_existing_jobs(jobs)

    channel_external_to_id_mapping = Channel.where(external_id: jobs.map(&:channel_external_id)).pluck(:external_id,
                                                                                                       :id).to_h
    stage_code_to_id_mapping = Stage.where(game_id: jobs.map(&:stage_game_id)).pluck(:game_id, :id).to_h

    jobs.each do |job|
      job.channel_id = channel_external_to_id_mapping[job.channel_external_id]
      job.stage_id = stage_code_to_id_mapping[job.stage_game_id]
    end
  end

  def bulk_import_extract_clear_data_from_video_jobs(jobs)
    ExtractClearDataFromVideoJob.import(jobs, validate: true)
  end

  def remove_existing_jobs(jobs)
    existing_video_urls = ExtractClearDataFromVideoJob.where(video_url: jobs.map(&:video_url)).pluck(:video_url)
    jobs.reject { |job| existing_video_urls.include?(job.video_url) }
  end

  def deserialize(data)
    URI::UID.parse(data).decode
  end

  def file=(value)
    super
    self.file_data =
      if file.respond_to?(:tempfile)
        file.tempfile.readlines
      else
        file.readlines
      end
  end
end
