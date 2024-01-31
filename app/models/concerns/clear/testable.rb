module Clear::Testable
  extend ActiveSupport::Concern

  included do
    has_one :test_case, dependent: :destroy

    after_save :create_test_case_using_job_id, if: :use_for_test_case
  end

  def create_test_case_using_job_id
    return unless ClearImage::TestCase.enabled?
    return if job_id.blank? || test_case.present?

    job = ExtractClearDataFromVideoJob.find_by(id: job_id)

    used_operators_data = used_operators.map do |operator|
      operator.attributes.slice('operator_id', 'skill', 'level', 'elite')
    end

    create_test_case(video_url: job.video_url, used_operators_data:)
  end
end
