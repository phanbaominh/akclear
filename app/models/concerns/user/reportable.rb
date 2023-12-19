module User::Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, dependent: :destroy
    has_many :reported_clears, class_name: 'Clear', through: :reports, source: :clear
  end

  def report(clear)
    reports.create(clear:)
  end

  def unreport(clear)
    reports.find_by(clear:).destroy
  end
end
