module Clear::Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, dependent: :destroy
    has_many :reporters, class_name: 'User', through: :reports, source: :reporter
  end

  def reported_by?(user)
    reporters.exists?(user.id)
  end

  def reported?
    reported_by?(Current.user)
  end
end
