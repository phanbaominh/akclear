# frozen_string_literal: true

class ExtractClearResultExporter
  def export(stream)
    channels.each do |channel|
      stream.write("#{serialize(channel)}\n")
    end
    extract_clear_jobs.find_each do |job|
      job.data&.dig('used_operators_attributes')&.map(&:compact_blank!)
      stream.write("#{serialize(job)}\n")
    end
  end

  def serialize(record)
    record.respond_to?(:to_uid) ? record.to_uid(serialize_options) : URI::UID.build(record, serialize_options).to_s
  end

  def serialize_options
    @serialize_options ||= { include_keys: false, include_timestamps: false, exclude: [:operator_name_only],
                             include_changes: true }.freeze
  end

  def channels
    @channels ||= Channel.all
  end

  def extract_clear_jobs
    @extract_clear_jobs ||= ExtractClearDataFromVideoJob.completed.includes(:channel, :stage)
  end
end
