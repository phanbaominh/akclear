# frozen_string_literal: true

class ImportClearExtractionResultJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :system
  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { 'import_clear_extraction_result_job' }
  )

  def perform(file_data)
    ExtractClearResultImporter.new(file_data:).import
  rescue StandardError => e
    Rails.logger.error("Failed to import clear extraction result: #{e.message}")
  end
end
