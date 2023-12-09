module Clear::Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, dependent: :destroy
    has_many :reporters, class_name: 'User', through: :reports, source: :reporter

    scope :reported, -> { joins(:reports) }
    scope :with_report_counts, -> { joins(:reports).group(:id).select(:id, 'COUNT(reports.id) AS reports_count') }
    delegate :count, to: :reports, prefix: true
  end

  def reported_by?(user)
    reporters.exists?(user.id)
  end

  def reported?
    reported_by?(Current.user)
  end
end
